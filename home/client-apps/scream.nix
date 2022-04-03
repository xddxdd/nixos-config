{ config, pkgs, lib, ... }:

{
  systemd.user.services.scream = {
    Service = {
      ExecStart = "${pkgs.scream}/bin/scream -i virbr0 -v";
      Restart = "always";
      RestartSec = "3";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
