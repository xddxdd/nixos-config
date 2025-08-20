{
  pkgs,
  LT,
  ...
}:
{
  systemd.services.usque = {
    description = "Usque";
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      if [ ! -f config.json ]; then
        yes | ${pkgs.nur-xddxdd.usque}/bin/usque register
      fi
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.nur-xddxdd.usque}/bin/usque socks -b 127.0.0.1 -p ${LT.portStr.Usque}";

      User = "usque";
      Group = "usque";

      StateDirectory = "usque";
      WorkingDirectory = "/var/lib/usque";
    };
  };

  users.users.usque = {
    group = "usque";
    isSystemUser = true;
  };
  users.groups.usque = { };
}
