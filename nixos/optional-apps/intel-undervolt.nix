{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  systemd.services.intel-undervolt = {
    after = ["multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target"];
    wantedBy = ["multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nixos-cn.intel-undervolt}/bin/intel-undervolt apply";
    };
  };
}
