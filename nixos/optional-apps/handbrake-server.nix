{
  LT,
  config,
  ...
}:
{
  virtualisation.oci-containers.containers.handbrake = {
    extraOptions = [
      "--ipc=host"
      "--gpus=all"
    ];
    image = "docker.io/zocker160/handbrake-nvenc:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    ports = [ "127.0.0.1:${LT.portStr.HandBrake}:5800" ];
    environment = {
      USER_ID = "1000";
      GROUP_ID = "1000";
      TZ = config.time.timeZone;
      KEEP_APP_RUNNING = "1";
      DARK_MODE = "1";
      AUTOMATED_CONVERSION = "0";
    };
    volumes = [
      "/var/lib/handbrake-server/config:/config"
      "/mnt/storage/handbrake-server/storage:/storage"
      "/mnt/storage/handbrake-server/output:/output"
    ];
  };

  systemd.services.podman-handbrake = {
    after = [ "mnt-storage.mount" ];
    requires = [ "mnt-storage.mount" ];
  };

  systemd.tmpfiles.settings = {
    archiveteam = {
      "/var/lib/handbrake-server/config"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
      "/mnt/storage/handbrake-server"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
      "/mnt/storage/handbrake-server/storage"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
      "/mnt/storage/handbrake-server/output"."d" = {
        mode = "755";
        user = "1000";
        group = "1000";
      };
    };
  };

  lantian.nginxVhosts."handbrake.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.HandBrake}";
      };
    };
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    accessibleBy = "private";
    noIndex.enable = true;
  };
}
