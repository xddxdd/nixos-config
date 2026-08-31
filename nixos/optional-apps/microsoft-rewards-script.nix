{
  config,
  inputs,
  ...
}:
{
  sops.secrets.microsoft-rewards-script-env.sopsFile =
    inputs.secrets + "/microsoft-rewards-script.yaml";

  virtualisation.oci-containers.containers.microsoft-rewards-script = {
    image = "ghcr.io/thenetsky/microsoft-rewards-script:4";
    labels."io.containers.autoupdate" = "registry";
    environment = {
      TZ = config.time.timeZone;
      NODE_ENV = "production";
      CRON_SCHEDULE = "0 9 * * *";
      RUN_ON_START = "true";
      SKIP_RANDOM_SLEEP = "false";
    };
    environmentFiles = [ config.sops.secrets.microsoft-rewards-script-env.path ];
    volumes = [
      "/var/lib/microsoft-rewards-script/config:/usr/src/microsoft-rewards-script/config"
      "/var/lib/microsoft-rewards-script/sessions:/usr/src/microsoft-rewards-script/sessions"
    ];
  };

  systemd.tmpfiles.settings = {
    microsoft-rewards-script = {
      "/var/lib/microsoft-rewards-script/config"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
      "/var/lib/microsoft-rewards-script/sessions"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };
}
