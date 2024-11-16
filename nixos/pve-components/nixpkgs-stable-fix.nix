{ lib, ... }:
{
  options = {
    hardware.graphics = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };

    services.userborn = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };
  };

  config = {
    # FIXME: remove after 24.11
    lantian.qemu-user-static-binfmt.enable = lib.mkForce false;
  };
}
