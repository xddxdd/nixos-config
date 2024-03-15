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
  systemd.user.services.nix-index-update = {
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix-index-update}/bin/nix-index-update";
    };
  };

  systemd.user.timers.nix-index-update = {
    Install = {
      WantedBy = [ "timers.target" ];
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "nix-index-update.service";
    };
  };
}
