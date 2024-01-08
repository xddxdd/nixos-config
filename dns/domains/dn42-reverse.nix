{
  pkgs,
  config,
  lib,
  LT,
  inputs,
  ...
} @ args: {
  domains = [
    rec {
      domain = "198.18.0.0/16";
      reverse = true;
      providers = ["bind"];
      records = lib.flatten [
        config.common.nameservers.LTNet
        (config.common.hostRecs.LTNetReverseIPv4_16 "ltnet.lantian.pub")
      ];
    }

    rec {
      domain = "198.19.0.0/16";
      reverse = true;
      providers = ["bind"];
      records = lib.flatten [
        config.common.nameservers.LTNet
        (config.common.hostRecs.LTNetReverseIPv4_16 "ltnet.lantian.pub")
      ];
    }

    rec {
      domain = "fdbc:f9dc:67ad::/48";
      reverse = true;
      providers = ["bind"];
      records = lib.flatten [
        config.common.nameservers.DN42
        (config.common.hostRecs.LTNetReverseIPv6_64 "lantian.dn42")
      ];
    }

    rec {
      domain = "184_29.76.22.172.in-addr.arpa";
      providers = ["bind"];
      records = lib.flatten [
        config.common.nameservers.DN42
        (config.common.hostRecs.DN42ReverseIPv4 "lantian.dn42" 184 191)
      ];
    }

    rec {
      domain = "96_27.76.22.172.in-addr.arpa";
      providers = ["bind"];
      records = lib.flatten [
        {
          recordType = "PTR";
          name = "108";
          target = "whois.lantian.dn42.";
        }
        {
          recordType = "PTR";
          name = "109";
          target = "dns-authoritative.lantian.dn42.";
        }
        {
          recordType = "PTR";
          name = "110";
          target = "dns-recursive.lantian.dn42.";
        }

        config.common.nameservers.DN42
        (config.common.hostRecs.DN42ReverseIPv4 "lantian.dn42" 96 127)
        (config.common.poem "" 98)
      ];
    }

    rec {
      domain = "10.127.10.0/24";
      reverse = true;
      providers = ["bind"];
      records = lib.flatten [
        config.common.nameservers.NeoNetwork
        (config.common.hostRecs.LTNetReverseIPv4_24 "lantian.neo")
      ];
    }

    rec {
      domain = "fd10:127:10::/48";
      reverse = true;
      providers = ["bind"];
      records = lib.flatten [
        config.common.nameservers.NeoNetwork
        (config.common.hostRecs.LTNetReverseIPv6_64 "lantian.neo")
      ];
    }
  ];
}
