{
  pkgs,
  config,
  LT,
  lib,
  ...
}:
{
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-enhanced-nox;
    user = "lantian";
    group = "users";
    profileDir = "/var/lib/qbittorrent";
    webuiPort = LT.port.qBitTorrent.WebUI;
    torrentingPort = LT.this.wg-lantian.forwardStart + LT.portForwardOffset.qBitTorrent;
    extraArgs = [
      "--confirm-legal-notice"
    ];
  };

  systemd.services.qbittorrent.preStart = ''
    ${pkgs.coreutils}/bin/rm -f -- /var/lib/qbittorrent/qBittorrent/config/lockfile
  '';

  systemd.services.qbittorrent.serviceConfig = {
    Restart = "always";
    RestartSec = "5";
    UMask = "0002";
    LimitNOFILE = 1048576;
    IOSchedulingClass = "idle";
    IOSchedulingPriority = "7";
    MemoryDenyWriteExecute = lib.mkForce false;
  };

  lantian.harden.qbittorrent.etc = {
    hosts = lib.mkDefault true;
    "ssl/certs/ca-certificates.crt" = lib.mkDefault true;
    "ssl/certs/ca-bundle.crt" =
      lib.mkDefault
        config.environment.etc."ssl/certs/ca-certificates.crt".source;
  };

  lantian.localVhosts.bt = {
    locations = {
      "/" = {
        allowCORS = true;
        proxyPass = "http://127.0.0.1:${LT.portStr.qBitTorrent.WebUI}";
      };
    };
  };
}
