{ pkgs, ... }:
let
  configFile = pkgs.writeText "config.yaml" (
    builtins.toJSON {
      matrix = {
        homeserver = "https://matrix.lantian.pub";
        bot_user_id = "@meshtastic:lantian.pub";
        prefix_enabled = true;
        prefix_format = "[{long}/{short}]: ";
      };
      matrix_rooms = [
        {
          id = "#meshtastic-longfast:lantian.pub";
          meshtastic_channel = 0;
        }
        {
          id = "#meshtastic-ps-mesh:lantian.pub";
          meshtastic_channel = 1;
        }
        {
          id = "#meshtastic-ps-mqtt:lantian.pub";
          meshtastic_channel = 2;
        }
      ];
      meshtastic = {
        connection_type = "serial";
        serial_port = "/dev/ttyUSB0";
        meshnet_name = "Lan Tian";
        message_interactions = {
          reactions = false;
          replies = false;
        };
        broadcast_enabled = true;
        prefix_enabled = false;
      };
      logging = {
        level = "info";
      };
      plugins = {
        require_bot_mention = true;
        ping = {
          active = true;
        };
        weather = {
          active = true;
          units = "imperial";
        };
        nodes = {
          active = true;
        };
      };
    }
  );
in
{
  virtualisation.oci-containers.containers.mmrelay = {
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    image = "ghcr.io/jeremiah-k/mmrelay:latest";
    user = "root:root";
    privileged = true;
    volumes = [
      "/var/lib/mmrelay:/app/data"
      "${configFile}:/app/config.yaml:ro"
      "/dev:/dev"
    ];
  };

  systemd.tmpfiles.settings = {
    mmrelay = {
      "/var/lib/mmrelay"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };
}
