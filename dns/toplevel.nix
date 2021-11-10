{ pkgs, dns, ... }:

with dns;
let
  hosts = import ../hosts.nix;

  commonHosts = import ./common-hosts.nix { inherit pkgs dns; };
  commonNameservers = import ./common-nameservers.nix { inherit pkgs dns; };
  commonPoem = import ./common-poem.nix { inherit pkgs dns; };

  lantianPub = import ./records-lantian-pub.nix { inherit pkgs dns; };
  xuyh0120Win = import ./records-xuyh0120-win.nix { inherit pkgs dns; };
in
dns.eval {
  providers = {
    bind = "BIND";
    cloudflare = "CLOUDFLAREAPI";
    henet = "HEDNS";
  };
  domains = [
    (rec {
      domain = "lantian.pub";
      providers = [ "cloudflare" ];
      records =
        [ ]
        ++ commonHosts.CAA
        ++ (commonHosts.Normal domain)
        ++ (commonHosts.SSHFP domain)
        ++ (commonHosts.TXT domain)
        ++ (commonHosts.Wildcard domain)
        ++ lantianPub.email
        ++ lantianPub.externalServices
        ++ lantianPub.internalServices
      ;
    })

    (rec {
      domain = "xuyh0120.win";
      providers = [ "cloudflare" ];
      records =
        [ ]
        ++ commonHosts.CAA
        ++ (commonHosts.Normal domain)
        ++ (commonHosts.SSHFP domain)
        ++ (commonHosts.Wildcard domain)
        ++ xuyh0120Win
      ;
    })

    (rec {
      domain = "lantian.pp.ua";
      providers = [ "henet" ];
      records =
        [
          (ALIAS { name = "@"; target = "xuyh0120.f3322.org."; ttl = "10m"; })
        ]
        ++ commonHosts.CAA
        ++ (commonHosts.Normal domain)
        ++ (commonHosts.SSHFP domain)
      ;
    })

    (rec {
      domain = "ltn.pp.ua";
      providers = [ "henet" ];
      records =
        [
          (ALIAS { name = "@"; target = "xuyh0120.f3322.org."; ttl = "10m"; })
        ]
        ++ commonHosts.CAA
        ++ (commonHosts.Normal domain)
        ++ (commonHosts.SSHFP domain)
      ;
    })

    (rec {
      domain = "xuyh0120.pp.ua";
      providers = [ "henet" ];
      records =
        [
          (ALIAS { name = "@"; target = "xuyh0120.f3322.org."; ttl = "10m"; })
        ]
        ++ commonHosts.CAA
        ++ (commonHosts.Normal domain)
        ++ (commonHosts.SSHFP domain)
      ;
    })

    (rec {
      domain = "lantian.eu.org";
      providers = [ "bind" ];
      records =
        [
          (AAAA { name = "@"; address = "2607:fcd0:100:b100::198a:b7f6"; ttl = "10m"; })
          (A { name = "@"; address = "185.186.147.110"; ttl = "10m"; })
          (CNAME { name = "*"; target = "@"; ttl = "10m"; })
        ]
        ++ (commonHosts.Normal domain)
        ++ (commonHosts.SSHFP domain)
        ++ (commonHosts.Wildcard domain)
        ++ commonNameservers.Public
      ;
    })

    (rec {
      domain = "neo.lantian.pub";
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.Public
        ++ (commonHosts.NeoNetwork domain)
      ;
    })

    (rec {
      domain = "dn42.lantian.pub";
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.Public
        ++ (commonHosts.DN42 domain)
      ;
    })

    (rec {
      domain = "zt.lantian.pub";
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.Public
        ++ (commonHosts.LTNet domain)
      ;
    })

    (rec {
      domain = "172.18.0.0/16";
      reverse = true;
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.LTNet
        ++ (commonHosts.LTNetReverseIPv4 "zt.lantian.pub")
      ;
    })

    (rec {
      domain = "184_29.76.22.172.in-addr.arpa";
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.DN42
        ++ (commonHosts.DN42ReverseIPv4 "lantian.dn42" 184 191)
      ;
    })

    (rec {
      domain = "96_27.76.22.172.in-addr.arpa";
      providers = [ "bind" ];
      records =
        [
          (PTR { name = "98"; target = "one.should.uphold.his.countrys.interest.with.his.life."; })
          (PTR { name = "99"; target = "he.should.not.do.things."; })
          (PTR { name = "100"; target = "just.to.pursue.his.personal.gains."; })
          (PTR { name = "101"; target = "and.he.should.not.evade.responsibilities."; })
          (PTR { name = "102"; target = "for.fear.of.personal.loss."; })
          (PTR { name = "108"; target = "whois.lantian.dn42."; })
          (PTR { name = "109"; target = "dns-authoritative.lantian.dn42."; })
          (PTR { name = "110"; target = "dns-recursive.lantian.dn42."; })
        ]
        ++ commonNameservers.DN42
        ++ (commonHosts.DN42ReverseIPv4 "lantian.dn42" 96 127)
      ;
    })

    (rec {
      domain = "10.127.10.0/24";
      reverse = true;
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.NeoNetwork
        ++ (commonHosts.NeoNetworkReverseIPv4 "lantian.neo")
      ;
    })

    (rec {
      domain = "fdbc:f9dc:67ad::/48";
      reverse = true;
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.DN42
        ++ (commonHosts.DN42ReverseIPv6 "lantian.dn42")
      ;
    })

    (rec {
      domain = "fd10:127:10::/48";
      reverse = true;
      providers = [ "bind" ];
      records =
        [ ]
        ++ commonNameservers.NeoNetwork
        ++ (commonHosts.NeoNetworkReverseIPv6 "lantian.neo")
      ;
    })

    (rec {
      domain = "lantian.dn42";
      providers = [ "bind" ];
      records =
        [
          (A { name = "ns1"; address = "172.22.76.186"; })
          (AAAA { name = "ns1"; address = "fdbc:f9dc:67ad:1::1"; })
          (A { name = "ns2"; address = "172.22.76.185"; })
          (AAAA { name = "ns2"; address = "fdbc:f9dc:67ad:3::1"; })
          (A { name = "ns3"; address = "172.22.76.190"; })
          (AAAA { name = "ns3"; address = "fdbc:f9dc:67ad:8::1"; })
          (A { name = "ns4"; address = "172.22.76.187"; })
          (AAAA { name = "ns4"; address = "fdbc:f9dc:67ad:2::1"; })
          (A { name = "ns5"; address = "172.22.76.188"; })
          (AAAA { name = "ns5"; address = "fdbc:f9dc:67ad:9::1"; })
          (A { name = "ns-anycast"; address = "172.22.76.109"; })
          (AAAA { name = "ns-anycast"; address = "fdbc:f9dc:67ad:2547::54"; })

          (A { name = "@"; address = "172.22.76.185"; ttl = "10m"; })
          (AAAA { name = "@"; address = "fdbc:f9dc:67ad::dd:c85a:8a93"; ttl = "10m"; })
          (CNAME { name = "*"; target = "@"; ttl = "10m"; })

          (A { name = "gopher"; address = "172.22.76.108"; })
          (AAAA { name = "gopher"; address = "fdbc:f9dc:67ad:2547::43"; })
          (A { name = "whois"; address = "172.22.76.108"; })
          (AAAA { name = "whois"; address = "fdbc:f9dc:67ad:2547::43"; })
          (A { name = "dns-authoritative"; address = "172.22.76.109"; })
          (AAAA { name = "dns-authoritative"; address = "fdbc:f9dc:67ad:2547::54"; })
          (A { name = "dns-recursive"; address = "172.22.76.110"; })
          (AAAA { name = "dns-recursive"; address = "fdbc:f9dc:67ad:2547::53"; })

          (NS { name = "dns-gatuno"; target = "ns1.gatuno.dn42."; })
        ]
        ++ commonNameservers.DN42
        ++ (commonHosts.DN42 domain)
        ++ (commonHosts.SSHFP domain)
        ++ (commonHosts.Wildcard domain)
      ;
    })

    (rec {
      domain = "lantian.neo";
      providers = [ "bind" ];
      records =
        [
          (AAAA { name = "ns1"; address = "fd10:127:10:1::1"; })
          (A { name = "ns1"; address = "10.127.10.1"; })
          (AAAA { name = "ns2"; address = "fd10:127:10:3::1"; })
          (A { name = "ns2"; address = "10.127.10.3"; })
          (AAAA { name = "ns3"; address = "fd10:127:10:8::1"; })
          (A { name = "ns3"; address = "10.127.10.8"; })
          (AAAA { name = "ns4"; address = "fd10:127:10:2::1"; })
          (A { name = "ns4"; address = "10.127.10.2"; })
          (AAAA { name = "ns5"; address = "fd10:127:10:9::1"; })
          (A { name = "ns5"; address = "10.127.10.9"; })
          (AAAA { name = "ns-anycast"; address = "fd10:127:10:2547::1"; })
          (A { name = "ns-anycast"; address = "10.127.10.254"; })

          (A { name = "gopher"; address = "10.127.10.243"; })
          (AAAA { name = "gopher"; address = "fd10:127:10:2547::43"; })
          (A { name = "whois"; address = "10.127.10.243"; })
          (AAAA { name = "whois"; address = "fd10:127:10:2547::43"; })
          (A { name = "dns-authoritative"; address = "10.127.10.254"; })
          (AAAA { name = "dns-authoritative"; address = "fd10:127:10:2547::54"; })
          (A { name = "dns-recursive"; address = "10.127.10.253"; })
          (AAAA { name = "dns-recursive"; address = "fd10:127:10:2547::53"; })

          (AAAA { name = "@"; address = "fd10:127:10:1::1"; ttl = "10m"; })
          (A { name = "@"; address = "10.127.10.1"; ttl = "10m"; })
          (CNAME { name = "*"; target = "@"; ttl = "10m"; })
        ]
        ++ commonNameservers.NeoNetwork
        ++ (commonHosts.NeoNetwork domain)
        ++ (commonHosts.SSHFP domain)
        ++ (commonHosts.Wildcard domain)
      ;
    })

    (rec {
      domain = "2001:470:fa1d::/48";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "50kvm.lantian.pub."; })
          (PTR { name = "2001:470:fa1d::1"; target = "50kvm.lantian.pub."; })
        ]
        ++ (commonPoem "2001:470:fa1d::");
    })

    (rec {
      domain = "2001:470:19:10bd::/64";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "50kvm.lantian.pub."; })
          (PTR { name = "2001:470:19:10bd::1"; target = "50kvm.lantian.pub."; })
        ]
        ++ (commonPoem "2001:470:19:10bd::");
    })

    (rec {
      domain = "2001:470:8a6d::/48";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "virmach-ny1g.lantian.pub."; })
          (PTR { name = "2001:470:8a6d::1"; target = "virmach-ny1g.lantian.pub."; })
        ]
        ++ (commonPoem "2001:470:8a6d::");
    })

    (rec {
      domain = "2001:470:1f07:54d::/64";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "virmach-ny1g.lantian.pub."; })
          (PTR { name = "2001:470:1f07:54d::1"; target = "virmach-ny1g.lantian.pub."; })
        ]
        ++ (commonPoem "2001:470:1f07:54d::");
    })

    (rec {
      domain = "2001:470:8d00::/48";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "virmach-ny6g.lantian.pub."; })
          (PTR { name = "2001:470:8d00::1"; target = "virmach-ny6g.lantian.pub."; })
        ]
        ++ (commonPoem "2001:470:8d00::");
    })

    (rec {
      domain = "2001:470:1f07:c6f::/64";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "virmach-ny6g.lantian.pub."; })
          (PTR { name = "2001:470:1f07:c6f::1"; target = "virmach-ny6g.lantian.pub."; })
        ]
        ++ (commonPoem "2001:470:1f07:c6f::");
    })

    (rec {
      domain = "2605:6400:cac6::/48";
      reverse = true;
      providers = [ "henet" ];
      records =
        [
          (PTR { name = "*"; target = "buyvm.lantian.pub."; })
          (PTR { name = "2605:6400:cac6::1"; target = "buyvm.lantian.pub."; })
        ]
        ++ (commonPoem "2605:6400:cac6::");
    })
  ];
}
