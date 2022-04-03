{ config, pkgs, lib, ... }:

{
  documentation = let
    forceNo = lib.mkOverride 1 false;
  in {
    enable = forceNo;
    dev.enable = forceNo;
    doc.enable = forceNo;
    info.enable = forceNo;
    man.enable = forceNo;
    nixos.enable = forceNo;
  };
}
