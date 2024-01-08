{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
  options = {
    common = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
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

    apexRecords = domain:
      config.common.hostRecs.mapAddresses {
        name = "${domain}.";
        addresses = fallbackServer.public;
        ttl = "10m";
      };
  };
}
