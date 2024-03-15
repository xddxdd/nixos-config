{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
lib.mkIf (LT.this.hasTag LT.tags.low-disk) {
  lantian.qemu-user-static-binfmt.enable = false;
}
