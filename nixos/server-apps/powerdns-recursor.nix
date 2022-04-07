{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  netns = LT.netns {
    name = "powerdns-recursor";
    enable = config.services.pdns-recursor.enable;
    announcedIPv4 = [
      "172.22.76.110"
      "172.18.0.253"
      "10.127.10.253"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::53"
      "fd10:127:10:2547::53"
    ];
    birdBindTo = [ "pdns-recursor.service" ];
  };
in
{
  services.pdns-recursor = {
    enable = true;
    dns.address = "0.0.0.0, ::";
    dns.allowFrom = [ "0.0.0.0/0" "::/0" ];
    forwardZones =
      let
        authoritativeZones = lib.genAttrs
          # NeoNetwork is covered by fwd-dn42-interconnect
          (with LT.constants; (dn42Zones ++ openNICZones))
          (k: builtins.concatStringsSep ";" [
            "172.22.76.109"
            "fdbc:f9dc:67ad:2547::54"
          ]);
        emercoinZones = lib.genAttrs
          LT.constants.emercoinZones
          (k: builtins.concatStringsSep ";" [
            "185.122.58.37"
            "2a06:8ec0:3::1:2c4e"
            "172.106.88.242"
            "2602:ffc5:30::1:5c47"
          ]);
      in
      authoritativeZones // emercoinZones // {
        # DN42
        "hack" = "172.31.0.5";
        "rzl" = "172.22.36.250";
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

      dofile("/nix/persistent/sync-servers/ltnet-scripts/pdns-recursor-conf/fwd-dn42-interconnect.lua")
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
      include-dir = "/nix/persistent/sync-servers/ltnet-scripts/pdns-recursor-conf";
      "forward-zones-recurse+=." = builtins.concatStringsSep ";" [
        "172.22.76.109:${LT.portStr.DNSUpstream}"
        "[fdbc:f9dc:67ad:2547::54]:${LT.portStr.DNSUpstream}"
      ];
    };
  };

  systemd.services = netns.setup // {
    pdns-recursor = netns.bind {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        ExecReload = [
          ""
          "${pkgs.pdns-recursor}/bin/rec_control reload-zones"
        ];
        User = lib.mkForce "container";
      };
    };
  };
}
