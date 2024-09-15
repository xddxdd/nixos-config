{ lib, ... }:
{
  options = {
    hardware.graphics = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };
  };
}
