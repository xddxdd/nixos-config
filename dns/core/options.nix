{ lib, ... }@args:
{
  options = {
    registrars = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    providers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    domains = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule (import ./options-domain.nix args));
      default = [ ];
    };

    recordHandlers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };
  };
}
