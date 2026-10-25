{
  LT,
  config,
  ...
}:
{
  services.ncps = {
    enable = true;
    server.addr = "192.168.0.4:${LT.portStr.Ncps}";
    cache = {
      inherit (config.networking) hostName;
      lru.schedule = "53 4 * * *";
      maxSize = "100G";
      signNarinfo = false;
      upstream = {
        urls = [ "https://cache.nixos.org" ] ++ LT.constants.nix.substituters;
        publicKeys = LT.constants.nix.trusted-public-keys;
      };
    };
  };

  # Fill the keys required by ensure-service-harden that upstream does not
  # set; ncps itself is already heavily hardened by the upstream module
  systemd.services.ncps.serviceConfig = {
    AmbientCapabilities = "";
    RemoveIPC = true;
    SystemCallErrorNumber = "EPERM";

    # The cache and migration lock must survive the confinement's tmpfs root.
    BindPaths = [
      config.services.ncps.cache.storage.local
      config.services.ncps.cache.tempPath
      "/run/ncps"
    ];
  };

  lantian.harden.ncps = {
    enable = true;
    # OpenTelemetry resolves the service UID even when exporting is disabled.
    passwd = true;
  };

  systemd.services.ncps.serviceConfig.RestartSec = "5s";
}
