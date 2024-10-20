{
  config,
  lib,
  LT,
  ...
}:
{
  domains = [
    rec {
      domain = "lantian.dn42";
      providers = [ "bind" ];
      records = lib.flatten [
        config.common.records.SIP

        (config.common.hostRecs.mapAddresses {
          name = "ns1.${domain}.";
          addresses = LT.hosts."v-ps-hkg".dn42;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns2.${domain}.";
          addresses = LT.hosts."v-ps-sjc".dn42;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns3.${domain}.";
          addresses = LT.hosts."virmach-ny1g".dn42;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns4.${domain}.";
          addresses = LT.hosts."buyvm".dn42;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns5.${domain}.";
          addresses = LT.hosts."hetzner-de".dn42;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns-anycast.${domain}.";
          addresses = {
            IPv4 = "172.22.76.109";
            IPv6 = "fdbc:f9dc:67ad:2547::54";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "${domain}.";
          addresses = config.common.fallbackServer.dn42;
          ttl = "10m";
        })

        (config.common.hostRecs.mapAddresses {
          name = "gopher.${domain}.";
          addresses = {
            IPv4 = "172.22.76.108";
            IPv6 = "fdbc:f9dc:67ad:2547::43";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "whois.${domain}.";
          addresses = {
            IPv4 = "172.22.76.108";
            IPv6 = "fdbc:f9dc:67ad:2547::43";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "dns-authoritative.${domain}.";
          addresses = {
            IPv4 = "172.22.76.109";
            IPv6 = "fdbc:f9dc:67ad:2547::54";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "dns-recursive.${domain}.";
          addresses = {
            IPv4 = "172.22.76.110";
            IPv6 = "fdbc:f9dc:67ad:2547::53";
          };
        })

        config.common.nameservers.DN42
        (config.common.hostRecs.DN42 "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
      ];
    }
  ];
}
