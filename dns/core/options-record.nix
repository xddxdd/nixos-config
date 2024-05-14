{ lib, ... }:
{ name, ... }:
{
  freeformType = lib.types.attrsOf lib.types.anything;
  options = {
    name = lib.mkOption { type = lib.types.str; };
    reverse = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    ttl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    cloudflare = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };

    # Other fields are handled via freeformType
  };
}
