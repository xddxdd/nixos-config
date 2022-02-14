{ pkgs, ... }:

let
  dns = import ./core/default.nix { inherit pkgs; };
  hosts = import ../hosts.nix;
  importArgs = { inherit pkgs dns hosts; };

  common = rec {
    inherit hosts;
    mainServer = hosts.hostdare;

    hostRecs = import ./common/host-recs.nix importArgs;
    nameservers = import ./common/nameservers.nix importArgs;
    poem = import ./common/poem.nix importArgs;
    records = import ./common/records.nix importArgs;
    reverse = import ./common/reverse.nix importArgs;

    apexRecords = domain:
      hostRecs.mapAddresses {
        name = "${domain}.";
        addresses = mainServer.public;
        ttl = "10m";
      };
    apexGeoDNS = domain:
      dns.ALIAS {
        name = "${domain}.";
        target = "geo.56631131.xyz."; # Hosted on NS1.com for GeoDNS
        ttl = "10m";
      };
  };
in
dns.eval {
  providers = {
    bind = "BIND";
    cloudflare = "CLOUDFLAREAPI";
    desec = "DESEC";
    henet = "HEDNS";
  };
  domains = builtins.map
    (f: import (./domains + "/${f}") { inherit pkgs dns common hosts; })
    (pkgs.lib.attrNames (builtins.readDir ./domains));
}
