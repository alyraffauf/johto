_: {
  flake.nixosModules.alloy = {config, ...}: let
    lokiUrl = "http://goldenrod.johto:3030/loki/api/v1/push";
  in {
    services.alloy.enable = true;

    environment.etc."alloy/config.alloy".text = ''
      loki.write "default" {
        endpoint {
          url = "${lokiUrl}"
        }
      }

      loki.relabel "journal" {
        forward_to = []

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }

        rule {
          source_labels = ["__journal__systemd_user_unit"]
          target_label  = "user_unit"
        }
      }

      loki.source.journal "read" {
        forward_to    = [loki.write.default.receiver]
        relabel_rules = loki.relabel.journal.rules
        max_age       = "12h"
        labels        = {
          job  = "systemd-journal",
          host = "${config.networking.hostName}",
        }
      }
    '';
  };
}
