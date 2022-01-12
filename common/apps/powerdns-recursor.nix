{ config, pkgs, ... }:

let
  LT = import ../helpers.nix { inherit config pkgs; };
in
{
  containers.powerdns-recursor = LT.container {
    name = "powerdns-recursor";

    announcedIPv4 = [
      "172.22.76.110"
      "172.18.0.253"
      "10.127.10.253"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::53"
      "fd10:127:10:2547::53"
    ];

    outerConfig = {
      bindMounts = {
        "/var/lib" = { hostPath = "/var/lib"; isReadOnly = false; };
      };
    };

    innerConfig = { ... }: {
      services.pdns-recursor = {
        enable = true;
        dns.address = "0.0.0.0, ::";
        dns.allowFrom = [ "0.0.0.0/0" "::/0" ];
        forwardZones = {
          # DN42
          "dn42" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "10.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "20.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "21.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "22.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "23.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "31.172.in-addr.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "d.f.ip6.arpa" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "hack" = "172.31.0.5";
          "rzl" = "172.22.36.250";

          # OpenNIC & FurNIC
          "bbs" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "chan" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "cyb" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "dns.opennic.glue" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "dyn" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "epic" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "fur" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "geek" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "gopher" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "indy" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "libre" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          #"neo" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "null" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "o" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "opennic.glue" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "oss" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "oz" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "parody" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";
          "pirate" = "172.22.76.109;fdbc:f9dc:67ad:2547::54";

          # Emercoin
          "bazar" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
          "coin" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
          "emc" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
          "lib" = "185.122.58.37;2a06:8ec0:3::1:2c4e;172.106.88.242;2602:ffc5:30::1:5c47";
        };
        luaConfig = ''
          addNTA("bbs")
          addNTA("chan")
          addNTA("cyb")
          addNTA("dns.opennic.glue")
          addNTA("dyn")
          addNTA("epic")
          addNTA("fur")
          addNTA("geek")
          addNTA("gopher")
          addNTA("indy")
          addNTA("libre")
          -- addNTA("neo")
          addNTA("null")
          addNTA("o")
          addNTA("opennic.glue")
          addNTA("oss")
          addNTA("oz")
          addNTA("parody")
          addNTA("pirate")

          -- Special DNS zone not handled by ltnet-scripts
          addNTA("rzl")

          -- Internal zones where DNSSEC will fail
          addNTA("lantian.dn42")
          addNTA("d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa")
          addNTA("lantian.neo")
          addNTA("10.127.10.in-addr.arpa")
          addNTA("0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa")
          addNTA("18.172.in-addr.arpa")

          dofile("/var/lib/powerdns-recursor/fwd-dn42-interconnect.lua")
        '';
        serveRFC1918 = false;
        settings = {
          any-to-tcp = "yes";
          dont-query = "";
          qname-minimization = "no";
          query-local-address = builtins.concatStringsSep ", " [
            "${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.powerdns-recursor}"
            "${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.powerdns-recursor}"
          ];
          reuseport = "yes";
          server-id = "lantian";
          tcp-fast-open = "128";
          include-dir = "/var/lib/powerdns-recursor";
          "forward-zones-recurse+=." = "172.22.76.109:56;[fdbc:f9dc:67ad:2547::54]:56";

          # Bypass some frequently queried domains from NextDNS
          "forward-zones-recurse+=epicgames.com" = "172.22.76.109:55;[fdbc:f9dc:67ad:2547::54]:55";
          "forward-zones-recurse+=community.humio.com" = "172.22.76.109:55;[fdbc:f9dc:67ad:2547::54]:55";
        };
      };
      systemd.services.pdns-recursor.serviceConfig = {
        DynamicUser = pkgs.lib.mkForce false;
        User = pkgs.lib.mkForce "container";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/powerdns-recursor 700 container container"
  ];
}
