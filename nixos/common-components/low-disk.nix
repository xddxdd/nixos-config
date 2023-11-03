{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args:
lib.mkIf (builtins.elem LT.tags.low-disk LT.this.tags) {
  lantian.qemu-user-static-binfmt.enable = false;
}
