{ pkgs, dns, common, ... }:

with dns;
[
  (rec {
    domain = "56631131.xyz";
    registrar = "doh";
    providers = [ "ns1" ];
    records = [
      common.hostRecs.CAA
      (A { name = "virmach-host"; address = "23.95.217.2"; })
      (A { name = "*.virmach-host"; address = "23.95.217.2"; })
      (IGNORE { name = "geo"; })
    ];
  })
]
