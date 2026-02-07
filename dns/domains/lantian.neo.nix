{
  config,
  lib,
  LT,
  ...
}:
{
  domains = [
    rec {
      domain = "lantian.neo";
      providers = [ "bind" ];
      records = lib.flatten [
        config.common.records.SIP

        (config.common.hostRecs.mapAddresses {
          name = "ns1.${domain}.";
          addresses = LT.hosts."alice".neonetwork;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns2.${domain}.";
          addresses = LT.hosts."bwg-lax".neonetwork;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns3.${domain}.";
          addresses = LT.hosts."virmach-ny1g".neonetwork;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns4.${domain}.";
          addresses = LT.hosts."buyvm".neonetwork;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns5.${domain}.";
          addresses = LT.hosts."colocrossing".neonetwork;
        })
        (config.common.hostRecs.mapAddresses {
          name = "ns-anycast.${domain}.";
          addresses = {
            IPv4 = "10.127.10.254";
            IPv6 = "fd10:127:10:2547::54";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "${domain}.";
          addresses = config.common.fallbackServer.neonetwork;
          ttl = "10m";
        })

        (config.common.hostRecs.mapAddresses {
          name = "gopher.${domain}.";
          addresses = {
            IPv4 = "10.127.10.243";
            IPv6 = "fd10:127:10:2547::43";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "whois.${domain}.";
          addresses = {
            IPv4 = "10.127.10.243";
            IPv6 = "fd10:127:10:2547::43";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "dns-authoritative.${domain}.";
          addresses = {
            IPv4 = "10.127.10.254";
            IPv6 = "fd10:127:10:2547::54";
          };
        })

        (config.common.hostRecs.mapAddresses {
          name = "dns-recursive.${domain}.";
          addresses = {
            IPv4 = "10.127.10.253";
            IPv6 = "fd10:127:10:2547::53";
          };
        })

        (config.common.records.DN42Email domain)
        {
          recordType = "TXT";
          name = "default._domainkey";
          contents = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5d/XapnRg+OrdvZStCJCpYbDwUgVnvgEd0IeAw6AcE+wRaFzdLDTiJFXF8rntcjNogE5/MOJrvzYK+2MgZg/mp+g75MpF/C+DkxAOCcsU2runIdpB9NZMC9cX+KIebm5WGhRjHZeHJbtmF0o7zXc6eEivIiIpq+mjiqijSzDBLNF6qCrCtc5Vt/mJvtY0r5gBvy1uGD5s3m0RYKfiBT4jAfGmfN4Tnys9c7gjntlmfNNfaObKjjcyBQ+MCX/UW6Q2o+UTwjSpEGiYXY3qdEHHaT8KT+TUkVbe/KNLKsLcl5nWnk+oVJvURIu5cv3RXQQEjqVYe8qFr030Z8h5zJAyQIDAQAB";
        }

        {
          recordType = "AAAA";
          name = "manosaba";
          address = "fd10:127:10:6d61:6e6f:7361:6261:14";
        }

        config.common.nameservers.NeoNetwork
        (config.common.hostRecs.NeoNetwork "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
      ];
    }
  ];
}
