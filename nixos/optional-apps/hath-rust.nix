{
  pkgs,
  LT,
  ...
}:
{
  systemd.services.hath-rust = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.hath-rust}/bin/hath-rust --port ${LT.portStr.Hath} --disable-logging --enable-metrics --enable-h3";

      User = "hath";
      Group = "hath";

      CacheDirectory = "hath";
      WorkingDirectory = "/var/cache/hath";
    };
  };

  users.users.hath = {
    group = "hath";
    isSystemUser = true;
  };
  users.groups.hath = { };
}
