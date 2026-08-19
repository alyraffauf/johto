import {
  access,
  chmod,
  mkdir,
  readFile,
  readdir,
  rename,
  rm,
  stat,
  writeFile,
} from "node:fs/promises";
import { basename, isAbsolute, join, resolve } from "node:path";

const REPOSITORY_ROOT = resolve(import.meta.dir, "..");
const HOSTS_DIRECTORY = join(import.meta.dir, "hosts");
const HOST_NAME_PATTERN = /^[a-z0-9][a-z0-9-]*$/;
const ALY_KEY_PATTERN = /^aly_.*\.pub$/;
const ALY_KEYS_PLACEHOLDER = "@ALY_SSH_KEYS@";
const TAILSCALE_KEY_PLACEHOLDER = "@TAILSCALE_AUTH_KEY@";
const REQUIRED_COMMANDS = ["curl", "qemu-img", "virsh", "virt-install"];

interface ImageDefinition {
  url: string;
  sha256: string;
}

interface VmDefinition {
  memoryMiB: number;
  virtualCpus: number;
  diskSize: string;
  storageDirectory: string;
  osVariant: string;
  network: string;
  tailscaleAuthKeyFile: string;
  image: ImageDefinition;
}

interface VmPaths {
  hostDirectory: string;
  userDataTemplate: string;
  metaData: string;
  imageDirectory: string;
  baseImage: string;
  vmDisk: string;
  runtimeDirectory: string;
  renderedUserData: string;
}

interface CliArguments {
  hostName: string;
  checkOnly: boolean;
}

type JsonObject = Record<string, unknown>;

async function main(): Promise<void> {
  const cliArguments = parseArguments(process.argv.slice(2));
  const definition = await loadDefinition(cliArguments.hostName);
  const paths = buildPaths(cliArguments.hostName, definition);
  const alySshKeys = await loadAlySshKeys();

  await validateCloudInitFiles(paths, alySshKeys);

  if (cliArguments.checkOnly) {
    console.log(
      `${cliArguments.hostName}: valid (${alySshKeys.length} Aly SSH keys)`,
    );
    return;
  }

  requireCommands();
  requireRoot(cliArguments.hostName);
  await requireLibvirtConnection();
  await requireActiveNetwork(definition.network);
  await requireMissingDomain(cliArguments.hostName);
  await requireMissingDisk(paths.vmDisk);
  await access(definition.tailscaleAuthKeyFile);
  await ensureBaseImage(definition.image, paths);

  try {
    await renderCloudInit(definition, paths, alySshKeys);
    await createVmDisk(definition, paths);
    await createVm(cliArguments.hostName, definition, paths);
  } finally {
    await rm(paths.runtimeDirectory, { recursive: true, force: true });
  }
}

function parseArguments(rawArguments: string[]): CliArguments {
  if (rawArguments.includes("--help") || rawArguments.includes("-h")) {
    printUsage();
    process.exit(0);
  }

  const checkOnly = rawArguments.includes("--check");
  const hostNames = rawArguments.filter((argument) => argument !== "--check");
  if (hostNames.length !== 1 || !HOST_NAME_PATTERN.test(hostNames[0] ?? "")) {
    printUsage();
    throw new Error(
      "Provide one host name using lowercase letters and dashes.",
    );
  }

  return { hostName: hostNames[0], checkOnly };
}

function printUsage(): void {
  console.log("Usage: bun run vms/create.ts <host> [--check]");
}

async function loadDefinition(hostName: string): Promise<VmDefinition> {
  const configPath = join(HOSTS_DIRECTORY, hostName, "vm.json");
  const json = JSON.parse(await readFile(configPath, "utf8")) as unknown;
  const config = requireObject(json, "VM configuration");

  return {
    memoryMiB: requirePositiveInteger(config, "memoryMiB"),
    virtualCpus: requirePositiveInteger(config, "virtualCpus"),
    diskSize: requireString(config, "diskSize"),
    storageDirectory: requireAbsolutePath(config, "storageDirectory"),
    osVariant: requireString(config, "osVariant"),
    network: requireString(config, "network"),
    tailscaleAuthKeyFile: requireAbsolutePath(config, "tailscaleAuthKeyFile"),
    image: parseImageDefinition(config.image),
  };
}

function requireObject(value: unknown, label: string): JsonObject {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error(`${label} must be an object.`);
  }

  return value as JsonObject;
}

function requireString(object: JsonObject, key: string): string {
  const value = object[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`${key} must be a non-empty string.`);
  }

  return value;
}

function requirePositiveInteger(object: JsonObject, key: string): number {
  const value = object[key];
  if (typeof value !== "number" || !Number.isInteger(value) || value <= 0) {
    throw new Error(`${key} must be a positive integer.`);
  }

  return value;
}

function requireAbsolutePath(object: JsonObject, key: string): string {
  const value = requireString(object, key);
  if (!isAbsolute(value)) {
    throw new Error(`${key} must be an absolute path.`);
  }

  return value;
}

function parseImageDefinition(value: unknown): ImageDefinition {
  const image = requireObject(value, "image");
  const url = requireString(image, "url");
  const sha256 = requireString(image, "sha256").toLowerCase();
  const parsedUrl = new URL(url);

  if (parsedUrl.protocol !== "https:") {
    throw new Error("image.url must use HTTPS.");
  }
  if (!/^[a-f0-9]{64}$/.test(sha256)) {
    throw new Error("image.sha256 must be a 64-character hexadecimal digest.");
  }
  if (basename(parsedUrl.pathname) === "") {
    throw new Error("image.url must end with a file name.");
  }

  return { url, sha256 };
}

function buildPaths(hostName: string, definition: VmDefinition): VmPaths {
  const hostDirectory = join(HOSTS_DIRECTORY, hostName);
  const imageFileName = basename(new URL(definition.image.url).pathname);
  const imageDirectory = join(definition.storageDirectory, "images");
  const runtimeDirectory = join("/run", `${hostName}-cloud-init`);

  return {
    hostDirectory,
    userDataTemplate: join(hostDirectory, "user-data.yaml.in"),
    metaData: join(hostDirectory, "meta-data.yaml"),
    imageDirectory,
    baseImage: join(imageDirectory, imageFileName),
    vmDisk: join(definition.storageDirectory, `${hostName}.qcow2`),
    runtimeDirectory,
    renderedUserData: join(runtimeDirectory, "user-data.yaml"),
  };
}

async function loadAlySshKeys(): Promise<string[]> {
  const keysDirectory = join(REPOSITORY_ROOT, "keys");
  const keyFiles = (await readdir(keysDirectory, { withFileTypes: true }))
    .filter((entry) => entry.isFile() && ALY_KEY_PATTERN.test(entry.name))
    .map((entry) => entry.name)
    .sort();

  if (keyFiles.length === 0) {
    throw new Error(`No Aly SSH public keys found in ${keysDirectory}.`);
  }

  return Promise.all(
    keyFiles.map(async (fileName) => {
      const key = (
        await readFile(join(keysDirectory, fileName), "utf8")
      ).trim();
      if (key === "") {
        throw new Error(`${fileName} is empty.`);
      }
      return key;
    }),
  );
}

async function validateCloudInitFiles(
  paths: VmPaths,
  alySshKeys: string[],
): Promise<void> {
  const [template, metaData] = await Promise.all([
    readFile(paths.userDataTemplate, "utf8"),
    readFile(paths.metaData, "utf8"),
  ]);

  renderUserData(template, alySshKeys, "validation-key");
  if (metaData.trim() === "") {
    throw new Error(`${paths.metaData} is empty.`);
  }
}

function requireRoot(hostName: string): void {
  if (process.getuid?.() !== 0) {
    throw new Error(`Run as root: sudo bun run vms/create.ts ${hostName}`);
  }
}

function requireCommands(): void {
  const missingCommands = REQUIRED_COMMANDS.filter(
    (command) => Bun.which(command) === null,
  );
  if (missingCommands.length > 0) {
    throw new Error(
      `Missing required commands: ${missingCommands.join(", ")}.`,
    );
  }
}

async function requireLibvirtConnection(): Promise<void> {
  const isConnected = await commandSucceeds([
    "virsh",
    "--connect",
    "qemu:///system",
    "list",
    "--all",
  ]);
  if (!isConnected) {
    throw new Error(
      "Cannot connect to qemu:///system; ensure libvirt is enabled and running.",
    );
  }
}

async function requireActiveNetwork(networkName: string): Promise<void> {
  const childProcess = Bun.spawn(
    ["virsh", "--connect", "qemu:///system", "net-list", "--name"],
    {
      stdout: "pipe",
      stderr: "inherit",
    },
  );
  const [exitCode, output] = await Promise.all([
    childProcess.exited,
    new Response(childProcess.stdout).text(),
  ]);
  if (exitCode !== 0) {
    throw new Error(`virsh exited with status ${exitCode}.`);
  }

  const activeNetworks = output.split(/\r?\n/).filter(Boolean);
  if (!activeNetworks.includes(networkName)) {
    throw new Error(
      `Libvirt network ${networkName} is missing or inactive; refusing to create a disk.`,
    );
  }
}

async function requireMissingDomain(hostName: string): Promise<void> {
  const exists = await commandSucceeds([
    "virsh",
    "--connect",
    "qemu:///system",
    "dominfo",
    hostName,
  ]);
  if (exists) {
    throw new Error(`${hostName} is already defined; refusing to change it.`);
  }
}

async function requireMissingDisk(diskPath: string): Promise<void> {
  if (await pathExists(diskPath)) {
    throw new Error(`${diskPath} already exists; refusing to overwrite it.`);
  }
}

async function ensureBaseImage(
  image: ImageDefinition,
  paths: VmPaths,
): Promise<void> {
  await mkdir(paths.imageDirectory, { recursive: true, mode: 0o750 });
  await chmod(paths.imageDirectory, 0o750);

  if (!(await pathExists(paths.baseImage))) {
    await downloadImage(image.url, paths.baseImage);
  }

  const actualSha256 = await hashFile(paths.baseImage);
  if (actualSha256 !== image.sha256) {
    await rm(paths.baseImage, { force: true });
    throw new Error(`Checksum mismatch for ${paths.baseImage}; removed it.`);
  }
}

async function downloadImage(url: string, destination: string): Promise<void> {
  const partialPath = `${destination}.partial`;

  try {
    await runCommand([
      "curl",
      "--fail",
      "--location",
      "--progress-bar",
      "--output",
      partialPath,
      url,
    ]);
    await rename(partialPath, destination);
  } catch (error) {
    await rm(partialPath, { force: true });
    throw error;
  }
}

async function hashFile(filePath: string): Promise<string> {
  const hasher = new Bun.CryptoHasher("sha256");
  for await (const chunk of Bun.file(filePath).stream()) {
    hasher.update(chunk);
  }
  return hasher.digest("hex");
}

async function renderCloudInit(
  definition: VmDefinition,
  paths: VmPaths,
  alySshKeys: string[],
): Promise<void> {
  const template = await readFile(paths.userDataTemplate, "utf8");
  const tailscaleAuthKey = (
    await readFile(definition.tailscaleAuthKeyFile, "utf8")
  ).trim();
  if (tailscaleAuthKey === "") {
    throw new Error(`${definition.tailscaleAuthKeyFile} is empty.`);
  }

  const userData = renderUserData(template, alySshKeys, tailscaleAuthKey);

  await mkdir(paths.runtimeDirectory, { recursive: true, mode: 0o700 });
  await chmod(paths.runtimeDirectory, 0o700);
  await writeFile(paths.renderedUserData, userData, { mode: 0o600 });
}

function renderUserData(
  template: string,
  alySshKeys: string[],
  tailscaleAuthKey: string,
): string {
  const authorizedKeys = alySshKeys
    .map((key) => `      - ${JSON.stringify(key)}`)
    .join("\n");
  const withAuthorizedKeys = replacePlaceholder(
    template,
    ALY_KEYS_PLACEHOLDER,
    authorizedKeys,
  );

  return replacePlaceholder(
    withAuthorizedKeys,
    TAILSCALE_KEY_PLACEHOLDER,
    JSON.stringify(tailscaleAuthKey),
  );
}

function replacePlaceholder(
  content: string,
  placeholder: string,
  replacement: string,
): string {
  const parts = content.split(placeholder);
  if (parts.length !== 2) {
    throw new Error(`Template must contain ${placeholder} exactly once.`);
  }

  return `${parts[0]}${replacement}${parts[1]}`;
}

async function createVmDisk(
  definition: VmDefinition,
  paths: VmPaths,
): Promise<void> {
  await runCommand([
    "qemu-img",
    "create",
    "-f",
    "qcow2",
    "-F",
    "qcow2",
    "-b",
    paths.baseImage,
    paths.vmDisk,
    definition.diskSize,
  ]);
}

async function createVm(
  hostName: string,
  definition: VmDefinition,
  paths: VmPaths,
): Promise<void> {
  await runCommand([
    "virt-install",
    "--connect",
    "qemu:///system",
    "--name",
    hostName,
    "--memory",
    String(definition.memoryMiB),
    "--vcpus",
    String(definition.virtualCpus),
    "--cpu",
    "host-passthrough",
    "--disk",
    `path=${paths.vmDisk},format=qcow2,bus=virtio`,
    "--import",
    "--os-variant",
    definition.osVariant,
    "--network",
    `network=${definition.network},model=virtio`,
    "--graphics",
    "none",
    "--cloud-init",
    `user-data=${paths.renderedUserData},meta-data=${paths.metaData}`,
    "--autostart",
    "--noautoconsole",
  ]);
}

async function commandSucceeds(command: string[]): Promise<boolean> {
  const childProcess = Bun.spawn(command, {
    stdout: "ignore",
    stderr: "ignore",
  });
  return (await childProcess.exited) === 0;
}

async function runCommand(command: string[]): Promise<void> {
  const childProcess = Bun.spawn(command, {
    stdout: "inherit",
    stderr: "inherit",
  });
  const exitCode = await childProcess.exited;
  if (exitCode !== 0) {
    throw new Error(`${command[0]} exited with status ${exitCode}.`);
  }
}

async function pathExists(path: string): Promise<boolean> {
  try {
    await stat(path);
    return true;
  } catch (error) {
    if (error instanceof Error && "code" in error && error.code === "ENOENT") {
      return false;
    }
    throw error;
  }
}

await main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`error: ${message}`);
  process.exitCode = 1;
});
