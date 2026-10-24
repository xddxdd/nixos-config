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
    ${pkgs.coreutils}/bin/rm -f -- /var/lib/qbittorrent-pt/qBittorrent/config/lockfile
  '';

  systemd.services.qbittorrent.serviceConfig = {
    BindReadOnlyPaths = [
      "${config.environment.etc.hosts.source}:/etc/hosts"
      "${
        config.environment.etc."ssl/certs/ca-certificates.crt".source
      }:/etc/ssl/certs/ca-certificates.crt"
      "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-bundle.crt"
    ];
    Restart = "always";
    RestartSec = "5";
    UMask = "0002";
    LimitNOFILE = 1048576;
    IOSchedulingClass = "idle";
    IOSchedulingPriority = "7";
    MemoryDenyWriteExecute = lib.mkForce false;
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
