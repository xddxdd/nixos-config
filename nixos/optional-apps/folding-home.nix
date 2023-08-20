{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.foldingathome = {
    enable = true;
    team = 3213; # https://folding.extremeoverclocking.com/team_summary.php?s=&t=3213
    user = "lantian";
    daemonNiceLevel = 19;
  };
}
