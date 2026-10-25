{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.peerbanhelper = {
    description = "Peer Ban Helper";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "qbittorrent.service"
      "qbittorrent-pt.service"
    ];
    requires = [ "network.target" ];

    serviceConfig = {
      RestartSec = "5s";
      User = "peerbanhelper";
      Group = "peerbanhelper";
      Restart = "on-failure";

      ExecStart = lib.getExe pkgs.nur-xddxdd.peerbanhelper;
      MemoryDenyWriteExecute = false;

      StateDirectory = "peerbanhelper";
      WorkingDirectory = "/var/lib/peerbanhelper";
      BindPaths = [ "/var/lib/peerbanhelper" ];
    };
  };
  lantian.harden.peerbanhelper.enable = true;

  lantian.localVhosts.peerbanhelper = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.PeerBanHelper}";
      };
    };
  };

  users.users.peerbanhelper = {
    group = "peerbanhelper";
    isSystemUser = true;
  };
  users.groups.peerbanhelper = { };
}
