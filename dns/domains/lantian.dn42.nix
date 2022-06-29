{ pkgs, lib, dns, common, hosts, ... }:

[
  (rec {
    domain = "lantian.dn42";
    providers = [ "bind" ];
    records = [
      (common.hostRecs.mapAddresses { name = "ns1.${domain}."; addresses = hosts."linkin".dn42; })
      (common.hostRecs.mapAddresses { name = "ns2.${domain}."; addresses = hosts."hostdare".dn42; })
      (common.hostRecs.mapAddresses { name = "ns3.${domain}."; addresses = hosts."virmach-ny1g".dn42; })
      (common.hostRecs.mapAddresses { name = "ns4.${domain}."; addresses = hosts."buyvm".dn42; })
      (common.hostRecs.mapAddresses { name = "ns5.${domain}."; addresses = hosts."soyoustart".dn42; })
      (common.hostRecs.mapAddresses {
        name = "ns-anycast.${domain}.";
        addresses = {
          IPv4 = "172.22.76.109";
          IPv6 = "fdbc:f9dc:67ad:2547::54";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "${domain}.";
        addresses = common.mainServer.dn42;
        ttl = "10m";
      })

      (common.hostRecs.mapAddresses {
        name = "gopher.${domain}.";
        addresses = {
          IPv4 = "172.22.76.108";
          IPv6 = "fdbc:f9dc:67ad:2547::43";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "whois.${domain}.";
        addresses = {
          IPv4 = "172.22.76.108";
          IPv6 = "fdbc:f9dc:67ad:2547::43";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "dns-authoritative.${domain}.";
        addresses = {
          IPv4 = "172.22.76.109";
          IPv6 = "fdbc:f9dc:67ad:2547::54";
        };
      })

      (common.hostRecs.mapAddresses {
        name = "dns-recursive.${domain}.";
        addresses = {
          IPv4 = "172.22.76.110";
          IPv6 = "fdbc:f9dc:67ad:2547::53";
        };
      })

      common.nameservers.DN42
      (common.hostRecs.DN42 domain)
      (common.hostRecs.SSHFP domain)
    ];
  })
]
