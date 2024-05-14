{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.powerdns-recursor;
in
lib.mkIf (!(LT.this.hasTag LT.tags.low-ram)) {
  lantian.netns.powerdns-recursor = {
    ipSuffix = "53";
    inherit (config.services.pdns-recursor) enable;
    announcedIPv4 = [
      "172.22.76.110"
      "198.19.0.253"
      "10.127.10.253"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::53"
      "fd10:127:10:2547::53"
    ];
    birdBindTo = [ "pdns-recursor.service" ];
  };

  services.pdns-recursor = {
    enable = true;
    dns.address = "0.0.0.0, ::";
    dns.allowFrom = [
      "0.0.0.0/0"
      "::/0"
    ];
    forwardZones =
      let
        authoritative =
          lib.genAttrs
            # NeoNetwork is covered by fwd-dn42-interconnect
            (with LT.constants.zones; (DN42 ++ OpenNIC ++ CRXN ++ Ltnet))
            (
              _k:
              builtins.concatStringsSep ";" [
                "198.19.0.254"
                "fdbc:f9dc:67ad:2547::54"
              ]
            );
        emercoin = lib.genAttrs LT.constants.zones.Emercoin (
          _k:
          builtins.concatStringsSep ";" [
            "185.122.58.37"
            "2a06:8ec0:3::1:2c4e"
            "172.106.88.242"
            "2602:ffc5:30::1:5c47"
          ]
        );
      in
      authoritative
      // emercoin
      // {
        # DN42
        "hack" = "172.31.0.5";
      };
    luaConfig =
      (lib.concatMapStringsSep "\n" (n: "addNTA(\"${n}\")") (
        with LT.constants.zones; (OpenNIC ++ Emercoin ++ CRXN ++ Ltnet)
      ))
      + ''
        dofile("/nix/persistent/sync-servers/ltnet-scripts/pdns-recursor-conf/fwd-dn42-interconnect.lua")
      '';
    serveRFC1918 = false;
    settings = {
      any-to-tcp = "yes";
      dont-query = "";
      loglevel = 3;
      qname-minimization = "no";
      query-local-address = builtins.concatStringsSep ", " [
        config.lantian.netns.powerdns-recursor.ipv4
        config.lantian.netns.powerdns-recursor.ipv6
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

  systemd.services = {
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
