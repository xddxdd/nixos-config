{
  config,
  lib,
  LT,
  ...
}:
{
  options = {
    common = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
    };
  };

  imports = [
    ./host-recs.nix
    ./nameservers.nix
    ./poem.nix
    ./records.nix
    ./reverse.nix
  ];

  config.common = rec {
    inherit (LT) hosts;
    fallbackServer = LT.hosts.v-ps-sjc;

    apexRecords =
      _domain:
      config.common.hostRecs.mapAddresses {
        name = "@";
        addresses = fallbackServer.public;
        ttl = "10m";
      };
  };
}
