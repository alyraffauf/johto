#!/bin/sh
set -eu

# Calibre-Web 0.6.27 expects this name; LinuxServer installs /usr/bin/kepubify.
ln -sf /usr/bin/kepubify /usr/bin/kepubify-linux-64bit
