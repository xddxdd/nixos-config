{ config, LT, ... }:
{
  virtualisation.oci-containers.containers.chinesesubfinder = {
    extraOptions = [
      "--pull"
      "always"
    ];
    environment = {
      PUID = "1000";
      PGID = "1000";
      PERMS = "false";
      TZ = config.time.timeZone;
      UMASK = "022";
    };
    image = "allanpk716/chinesesubfinder:latest-lite";
    ports = [
      "${LT.this.ltnet.IPv4}:19035:19035"
      "${LT.this.ltnet.IPv4}:19037:19037"
    ];
    volumes = [
      "/var/lib/chinesesubfinder:/config"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/chinesesubfinder 755 1000 1000"
  ];
}
