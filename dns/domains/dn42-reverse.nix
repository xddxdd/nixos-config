{
  pkgs,
  lib,
  dns,
  common,
  ...
}: [
  rec {
    domain = "198.18.0.0/16";
    reverse = true;
    providers = ["bind"];
    records = [
      common.nameservers.LTNet
      (common.hostRecs.LTNetReverseIPv4 "ltnet.lantian.pub")
    ];
  }

  rec {
    domain = "184_29.76.22.172.in-addr.arpa";
    providers = ["bind"];
    records = [
      common.nameservers.DN42
      (common.hostRecs.DN42ReverseIPv4 "lantian.dn42" 184 191)
    ];
  }

  rec {
    domain = "96_27.76.22.172.in-addr.arpa";
    providers = ["bind"];
    records = [
      (dns.PTR {
        name = "108";
        target = "whois.lantian.dn42.";
      })
      (dns.PTR {
        name = "109";
        target = "dns-authoritative.lantian.dn42.";
      })
      (dns.PTR {
        name = "110";
        target = "dns-recursive.lantian.dn42.";
      })

      common.nameservers.DN42
      (common.hostRecs.DN42ReverseIPv4 "lantian.dn42" 96 127)
      (common.poem "" 98)
    ];
  }

  rec {
    domain = "10.127.10.0/24";
    reverse = true;
    providers = ["bind"];
    records = [
      common.nameservers.NeoNetwork
      (common.hostRecs.NeoNetworkReverseIPv4 "lantian.neo")
    ];
  }

  rec {
    domain = "fdbc:f9dc:67ad::/48";
    reverse = true;
    providers = ["bind"];
    records = [
      common.nameservers.DN42
      (common.hostRecs.DN42ReverseIPv6 "lantian.dn42")
    ];
  }

  rec {
    domain = "fd10:127:10::/48";
    reverse = true;
    providers = ["bind"];
    records = [
      common.nameservers.NeoNetwork
      (common.hostRecs.NeoNetworkReverseIPv6 "lantian.neo")
    ];
  }
]
