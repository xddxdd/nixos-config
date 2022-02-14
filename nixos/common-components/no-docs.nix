{ config, pkgs, ... }:

{
  documentation = let
    forceNo = pkgs.lib.mkOverride 1 false;
  in {
    enable = forceNo;
    dev.enable = forceNo;
    doc.enable = forceNo;
    info.enable = forceNo;
    man.enable = forceNo;
    nixos.enable = forceNo;
  };
}
