{ pkgs, lib, dns, hosts, ... }@args:

rec {
  inherit hosts;
  mainServer = hosts.oneprovider;

  hostRecs = import ./host-recs.nix args;
  nameservers = import ./nameservers.nix args;
  poem = import ./poem.nix args;
  records = import ./records.nix args;
  reverse = import ./reverse.nix args;

  apexRecords = domain:
    hostRecs.mapAddresses {
      name = "${domain}.";
      addresses = mainServer.public;
      ttl = "10m";
    };
}
