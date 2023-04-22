{
  pkgs,
  lib,
  dns,
  common,
  hosts,
  ...
}: [
  rec {
    domain = "lantian.neo";
    providers = ["bind"];
    records = [
      common.records.SIP

      (common.hostRecs.mapAddresses {
        name = "ns1.${domain}.";
        addresses = hosts."v-ps-hkg".neonetwork;
      })
      (common.hostRecs.mapAddresses {
        name = "ns2.${domain}.";
        addresses = hosts."v-ps-sjc".neonetwork;
      })
      (common.hostRecs.mapAddresses {
        name = "ns3.${domain}.";
        addresses = hosts."virmach-ny1g".neonetwork;
      })
      (common.hostRecs.mapAddresses {
        name = "ns4.${domain}.";
        addresses = hosts."buyvm".neonetwork;
      })
      (common.hostRecs.mapAddresses {
        name = "ns5.${domain}.";
        addresses = hosts."hetzner-de".neonetwork;
      })
      (common.hostRecs.mapAddresses {
        name = "ns-anycast.${domain}.";
        addresses = {
          IPv4 = "10.127.10.254";
          IPv6 = "fd10:127:10:2547::54";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "${domain}.";
        addresses = common.fallbackServer.neonetwork;
        ttl = "10m";
      })

      (common.hostRecs.mapAddresses {
        name = "gopher.${domain}.";
        addresses = {
          IPv4 = "10.127.10.243";
          IPv6 = "fd10:127:10:2547::43";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "whois.${domain}.";
        addresses = {
          IPv4 = "10.127.10.243";
          IPv6 = "fd10:127:10:2547::43";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "dns-authoritative.${domain}.";
        addresses = {
          IPv4 = "10.127.10.254";
          IPv6 = "fd10:127:10:2547::54";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "dns-recursive.${domain}.";
        addresses = {
          IPv4 = "10.127.10.253";
          IPv6 = "fd10:127:10:2547::53";
        };
      })

      common.nameservers.NeoNetwork
      (common.hostRecs.NeoNetwork domain)
      (common.hostRecs.SSHFP domain)
    ];
  }
]
