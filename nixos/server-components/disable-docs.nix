{ lib, ... }:
{
  documentation = {
    dev.enable = lib.mkForce false;
    doc.enable = lib.mkForce false;
    enable = lib.mkForce false;
    info.enable = lib.mkForce false;
    man.enable = lib.mkForce false;
    man.man-db.enable = lib.mkForce false;
    man.mandoc.enable = lib.mkForce false;
    nixos.enable = lib.mkForce false;
  };
}
