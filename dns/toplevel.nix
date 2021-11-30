{ pkgs, dns, ... }:

with dns;
let
  hosts = import ../hosts.nix;
  mainServer = hosts.hostdare;

  commonHosts = import ./common-hosts.nix { inherit pkgs dns; };
  commonNameservers = import ./common-nameservers.nix { inherit pkgs dns; };
  commonPoem = import ./common-poem.nix { inherit pkgs dns; };
  commonRecords = import ./common-records.nix { inherit pkgs dns; };
  commonReverse = import ./common-reverse.nix { inherit pkgs dns; };

  apexRecords = domain:
    commonHosts.mapAddresses {
      name = "${domain}.";
      addresses = mainServer.public;
      ttl = "1h";
    };
  apexGeoDNS = domain: ALIAS {
    name = "${domain}.";
    target = "geo.56631131.xyz."; # Hosted on NS1.com for GeoDNS
    ttl = "10m";
  };

  lantianPub = import ./records-lantian-pub.nix { inherit pkgs dns; };
  xuyh0120Win = import ./records-xuyh0120-win.nix { inherit pkgs dns; };
in
dns.eval {
  providers = {
    bind = "BIND";
    cloudflare = "CLOUDFLAREAPI";
    desec = "DESEC";
    henet = "HEDNS";
  };
  domains = [
    (rec {
      domain = "lantian.pub";
      providers = [ "cloudflare" ];
      records = [
        (apexGeoDNS domain)
        commonHosts.CAA
        (commonHosts.Normal domain true)
        (commonHosts.SSHFP domain)
        (commonHosts.TXT domain)
        commonRecords.ForwardEmail
        lantianPub.email
        lantianPub.externalServices
        lantianPub.internalServices
        (commonHosts.LTNet "zt.${domain}" true)
        (commonHosts.DN42 "dn42.${domain}" true)
        (commonHosts.NeoNetwork "neo.${domain}" true)
      ];
    })

    (rec {
      domain = "xuyh0120.win";
      providers = [ "cloudflare" ];
      records = [
        (apexGeoDNS domain)
        commonHosts.CAA
        (commonHosts.Normal domain true)
        (commonHosts.SSHFP domain)
        commonRecords.ForwardEmail
        xuyh0120Win
      ];
    })

    (rec {
      domain = "lantian.pp.ua";
      providers = [ "henet" "desec" ];
      records = [
        (apexRecords domain)
        commonHosts.CAA
        (commonHosts.Normal domain false)
        (commonHosts.SSHFP domain)
      ];
    })

    (rec {
      domain = "ltn.pp.ua";
      providers = [ "henet" "desec" ];
      records = [
        (apexRecords domain)
        commonHosts.CAA
        (commonHosts.Normal domain false)
        (commonHosts.SSHFP domain)
      ];
    })

    (rec {
      domain = "xuyh0120.pp.ua";
      providers = [ "henet" "desec" ];
      records = [
        (apexRecords domain)
        commonHosts.CAA
        (commonHosts.Normal domain false)
        (commonHosts.SSHFP domain)
      ];
    })

    (rec {
      domain = "lantian.eu.org";
      providers = [ "bind" "desec" ];
      records = [
        (apexRecords domain)
        (commonHosts.Normal domain true)
        (commonHosts.SSHFP domain)
        commonNameservers.Public
      ];
    })

    (rec {
      domain = "172.18.0.0/16";
      reverse = true;
      providers = [ "bind" ];
      records = [
        commonNameservers.LTNet
        (commonHosts.LTNetReverseIPv4 "zt.lantian.pub")
      ];
    })

    (rec {
      domain = "184_29.76.22.172.in-addr.arpa";
      providers = [ "bind" ];
      records = [
        commonNameservers.DN42
        (commonHosts.DN42ReverseIPv4 "lantian.dn42" 184 191)
      ];
    })

    (rec {
      domain = "96_27.76.22.172.in-addr.arpa";
      providers = [ "bind" ];
      records = [
        (PTR { name = "108"; target = "whois.lantian.dn42."; })
        (PTR { name = "109"; target = "dns-authoritative.lantian.dn42."; })
        (PTR { name = "110"; target = "dns-recursive.lantian.dn42."; })

        commonNameservers.DN42
        (commonHosts.DN42ReverseIPv4 "lantian.dn42" 96 127)
        (commonPoem "" 98)
      ];
    })

    (rec {
      domain = "10.127.10.0/24";
      reverse = true;
      providers = [ "bind" ];
      records = [
        commonNameservers.NeoNetwork
        (commonHosts.NeoNetworkReverseIPv4 "lantian.neo")
      ];
    })

    (rec {
      domain = "fdbc:f9dc:67ad::/48";
      reverse = true;
      providers = [ "bind" ];
      records = [
        commonNameservers.DN42
        (commonHosts.DN42ReverseIPv6 "lantian.dn42")
      ];
    })

    (rec {
      domain = "fd10:127:10::/48";
      reverse = true;
      providers = [ "bind" ];
      records = [
        commonNameservers.NeoNetwork
        (commonHosts.NeoNetworkReverseIPv6 "lantian.neo")
      ];
    })

    (rec {
      domain = "lantian.dn42";
      providers = [ "bind" ];
      records = [
        (commonHosts.mapAddresses { name = "ns1.${domain}."; addresses = hosts."50kvm".dn42; })
        (commonHosts.mapAddresses { name = "ns2.${domain}."; addresses = hosts."hostdare".dn42; })
        (commonHosts.mapAddresses { name = "ns3.${domain}."; addresses = hosts."virmach-ny1g".dn42; })
        (commonHosts.mapAddresses { name = "ns4.${domain}."; addresses = hosts."buyvm".dn42; })
        (commonHosts.mapAddresses { name = "ns5.${domain}."; addresses = hosts."virmach-nl1g".dn42; })
        (commonHosts.mapAddresses {
          name = "ns-anycast.${domain}.";
          addresses = {
            IPv4 = "172.22.76.109";
            IPv6 = "fdbc:f9dc:67ad:2547::54";
          };
        })

        (commonHosts.mapAddresses {
          name = "${domain}.";
          addresses = mainServer.dn42;
          enableWildcard = true;
          ttl = "10m";
        })

        (commonHosts.mapAddresses {
          name = "gopher.${domain}.";
          addresses = {
            IPv4 = "172.22.76.108";
            IPv6 = "fdbc:f9dc:67ad:2547::43";
          };
        })

        (commonHosts.mapAddresses {
          name = "whois.${domain}.";
          addresses = {
            IPv4 = "172.22.76.108";
            IPv6 = "fdbc:f9dc:67ad:2547::43";
          };
        })

        (commonHosts.mapAddresses {
          name = "dns-authoritative.${domain}.";
          addresses = {
            IPv4 = "172.22.76.109";
            IPv6 = "fdbc:f9dc:67ad:2547::54";
          };
        })

        (commonHosts.mapAddresses {
          name = "dns-recursive.${domain}.";
          addresses = {
            IPv4 = "172.22.76.110";
            IPv6 = "fdbc:f9dc:67ad:2547::53";
          };
        })

        commonNameservers.DN42
        (commonHosts.DN42 domain true)
        (commonHosts.SSHFP domain)
      ];
    })

    (rec {
      domain = "lantian.neo";
      providers = [ "bind" ];
      records = [
        (commonHosts.mapAddresses { name = "ns1.${domain}."; addresses = hosts."50kvm".neonetwork; })
        (commonHosts.mapAddresses { name = "ns2.${domain}."; addresses = hosts."hostdare".neonetwork; })
        (commonHosts.mapAddresses { name = "ns3.${domain}."; addresses = hosts."virmach-ny1g".neonetwork; })
        (commonHosts.mapAddresses { name = "ns4.${domain}."; addresses = hosts."buyvm".neonetwork; })
        (commonHosts.mapAddresses { name = "ns5.${domain}."; addresses = hosts."virmach-nl1g".neonetwork; })
        (commonHosts.mapAddresses {
          name = "ns-anycast.${domain}.";
          addresses = {
            IPv4 = "10.127.10.254";
            IPv6 = "fd10:127:10:2547::54";
          };
        })

        (commonHosts.mapAddresses {
          name = "${domain}.";
          addresses = mainServer.neonetwork;
          enableWildcard = true;
          ttl = "10m";
        })

        (commonHosts.mapAddresses {
          name = "gopher.${domain}.";
          addresses = {
            IPv4 = "10.127.10.243";
            IPv6 = "fd10:127:10:2547::43";
          };
        })

        (commonHosts.mapAddresses {
          name = "whois.${domain}.";
          addresses = {
            IPv4 = "10.127.10.243";
            IPv6 = "fd10:127:10:2547::43";
          };
        })

        (commonHosts.mapAddresses {
          name = "dns-authoritative.${domain}.";
          addresses = {
            IPv4 = "10.127.10.254";
            IPv6 = "fd10:127:10:2547::54";
          };
        })

        (commonHosts.mapAddresses {
          name = "dns-recursive.${domain}.";
          addresses = {
            IPv4 = "10.127.10.253";
            IPv6 = "fd10:127:10:2547::53";
          };
        })

        commonNameservers.NeoNetwork
        (commonHosts.NeoNetwork domain true)
        (commonHosts.SSHFP domain)
      ];
    })

    (commonReverse { prefix = "2001:470:fa1d::/48"; target = "50kvm.lantian.pub."; })
    (commonReverse { prefix = "2001:470:19:10bd::/64"; target = "50kvm.lantian.pub."; })
    (commonReverse { prefix = "2001:470:8a6d::/48"; target = "virmach-ny1g.lantian.pub."; })
    (commonReverse { prefix = "2001:470:1f07:54d::/64"; target = "virmach-ny1g.lantian.pub."; })
    (commonReverse { prefix = "2001:470:8d00::/48"; target = "virmach-ny6g.lantian.pub."; })
    (commonReverse { prefix = "2001:470:1f07:c6f::/64"; target = "virmach-ny6g.lantian.pub."; })
    (commonReverse { prefix = "2605:6400:cac6::/48"; target = "buyvm.lantian.pub."; })
  ];
}
