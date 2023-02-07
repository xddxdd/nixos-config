{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  # https://github.com/NayamAmarshe/ToucheggKDE
  environment.etc."xdg/touchegg/touchegg.conf".source = ./touchegg.xml;

  services.touchegg.enable = true;

  systemd.user.services.touchegg = {
    description = "Touchegg Client";
    wantedBy = [ "default.target" ];
    path = with pkgs; [ qt6.qttools ];
    serviceConfig = {
      ExecStart = "${pkgs.touchegg}/bin/touchegg --quiet";
      Restart = "always";
      RestartSec = "3";
    };
  };
}
