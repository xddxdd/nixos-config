{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  py = pkgs.python3.withPackages (p: [
    pkgs.smartrent_py
  ]);
in {
  age.secrets.smartrent-env = {
    file = inputs.secrets + "/smartrent-env.age";
    owner = "smartrent-auto-lock";
    group = "smartrent-auto-lock";
  };

  systemd.services.smartrent-auto-lock = {
    description = "SmartRent Auto Lock";
    wantedBy = ["multi-user.target"];
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "10";
        ExecStart = "${py}/bin/python3 ${./script.py}";
        EnvironmentFile = config.age.secrets.smartrent-env.path;
        User = "smartrent-auto-lock";
        Group = "smartrent-auto-lock";
      };
  };

  users.users.smartrent-auto-lock = {
    group = "smartrent-auto-lock";
    isSystemUser = true;
  };
  users.groups.smartrent-auto-lock = {};
}
