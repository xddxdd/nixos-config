{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  systemd.services.peerbanhelper = {
    description = "Peer Ban Helper";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "qbittorrent.service"
      "transmission.service"
    ];
    requires = [ "network.target" ];

    serviceConfig = LT.serviceHarden // {
      User = "peerbanhelper";
      Group = "peerbanhelper";
      Restart = "on-failure";

      ExecStart = "${pkgs.peerbanhelper}/bin/peerbanhelper";
      MemoryDenyWriteExecute = false;

      StateDirectory = "peerbanhelper";
      WorkingDirectory = "/var/lib/peerbanhelper";
    };
  };

  users.users.peerbanhelper = {
    group = "peerbanhelper";
    isSystemUser = true;
  };
  users.groups.peerbanhelper = { };
}
