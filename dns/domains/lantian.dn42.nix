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
          addresses = LT.hosts."alice".dn42;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns2.${domain}.";
          addresses = LT.hosts."bwg-lax".dn42;
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
          addresses = LT.hosts."colocrossing".dn42;
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

        (config.common.records.DN42Email domain)
        {
          recordType = "TXT";
          name = "default._domainkey";
          contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv9N9lG6S9PcWRK/BsUHnzZNffkw+IQcQdy4kZY6XcSlaJyNf3S2UTsx8RzxTavI5h2VvwI0ha0pIbdrsKXLUCC33RoeEQuIMR+z1l8GYT0Ng8qpQIN/bqzgiXEVmxLlaPEx9R88kyh8B9ajGXMUbR+l07QTsZ4J1vmQr8wyE+1J9ODkjUEx6IAenuxezZyb5XPE2lyFKfBifTCKrNa+tDmUK9474NOFAKXPECNiZyvBcaKHumA3kgi4JP4aBFMP7oMeNsp9l8Q3L+EI2HNduU4aFzEK5mSdSKsHJkgoYj+Rf/M7kg8jLQEvKOb7uHarpNSIFFrvwL/QhtPij+qpqRQIDAQAB";
        }

        {
          recordType = "AAAA";
          name = "manosaba";
          address = "fdbc:f9dc:67ad:6d61:6e6f:7361:6261:14";
        }

        config.common.nameservers.DN42
        (config.common.hostRecs.DN42 "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
      ];
    }
  ];
}
