{ pkgs, lib, dns, common, ... }:

with dns;
[
  rec {
    domain = "56631131.xyz";
    registrar = "doh";
    providers = [ "ns1" ];
    records = [
      common.hostRecs.CAA
      common.records.Libravatar
      (A { name = "virmach-host"; address = "23.95.217.2"; })
      (A { name = "*.virmach-host"; address = "23.95.217.2"; })
      (IGNORE { name = "geo"; })

      (NS { name = "xip"; target = "ns-aws.sslip.io."; })
      (NS { name = "xip"; target = "ns-gce.sslip.io."; })
      (NS { name = "xip"; target = "ns-azure.sslip.io."; })
    ];
  }
]
