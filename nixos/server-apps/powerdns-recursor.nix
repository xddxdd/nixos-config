{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.powerdns-recursor;

  forwardZones =
    let
      authoritative =
        builtins.map
          (k: {
            zone = k;
            forwarders = [
              "198.19.0.254"
              "fdbc:f9dc:67ad:2547::54"
            ];
          })
          # NeoNetwork is covered by fwd-dn42-interconnect
          (with LT.constants.zones; (DN42 ++ OpenNIC ++ CRXN ++ Meshname ++ Ltnet));

      emercoin = builtins.map (k: {
        zone = k;
        forwarders = [
          "185.122.58.37"
          "2a06:8ec0:3::1:2c4e"
          "172.106.88.242"
          "2602:ffc5:30::1:5c47"
        ];
      }) LT.constants.zones.Emercoin;

      yggdrasilAlfis = builtins.map (k: {
        zone = k;
        forwarders = [
          "fdbc:f9dc:67ad:2547::52"
        ];
      }) LT.constants.zones.YggdrasilAlfis;

      hack = [
        {
          zone = "hack";
          forwarders = [ "172.31.0.5" ];
        }
      ];
    in
    authoritative ++ emercoin ++ yggdrasilAlfis ++ hack;

  forwardZonesRecurse =
    let
      azurePrivateDNS = [
        {
          zone = "database.azure.com";
          forwarders = [ "168.63.129.16" ];
        }
      ];
      all = [
        {
          zone = ".";
          forwarders = [
            "8.8.8.8"
            "2001:4860:4860::8888"
          ];
        }
      ];
    in
    azurePrivateDNS ++ all;
in
lib.mkIf (!(LT.this.hasTag LT.tags.low-ram)) {
  networking.nameservers = lib.mkBefore [ "198.19.0.253" ];

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
    dns.address = [
      "0.0.0.0"
      "::"
    ];
    dns.allowFrom = [
      "0.0.0.0/0"
      "::/0"
    ];
    luaConfig =
      let
        ntaRecords = lib.concatMapStringsSep "\n" (n: "addNTA(\"${n}\")") (
          with LT.constants.zones;
          (DN42 ++ OpenNIC ++ Emercoin ++ CRXN ++ Meshname ++ YggdrasilAlfis ++ Ltnet ++ Others)
        );
      in
      ''
        rpzFile("${LT.sources.delegacy-rpz.src}/rpz.delegacy.monostack.org.zone")

        ${ntaRecords}
        dofile("/nix/persistent/sync-servers/ltnet-scripts/pdns-recursor-conf/fwd-dn42-interconnect.lua")
      '';
    serveRFC1918 = false;
    yaml-settings = {
      incoming = {
        reuseport = true;
        tcp_fast_open = 128;
      };
      recursor = {
        any_to_tcp = true;
        qname_minimization = false;
        server_id = "${config.networking.hostName}.lantian.pub";
        forward_zones_file = "/nix/persistent/sync-servers/ltnet-scripts/pdns-recursor-conf/fwd-dn42-interconnect.yml";
        forward_zones = forwardZones;
        forward_zones_recurse = forwardZonesRecurse;
      };
      outgoing = {
        dont_query = [ ];
        source_address = [
          config.lantian.netns.powerdns-recursor.ipv4
          config.lantian.netns.powerdns-recursor.ipv6
        ];
      };

      # # Only enable when debugging!
      # dnssec.log_bogus = true;
      # logging.trace = "fail";
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
        User = lib.mkForce "pdns-recursor";
        Group = lib.mkForce "pdns-recursor";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };

  users.users.pdns-recursor = {
    group = "pdns-recursor";
    isSystemUser = true;
  };
  users.groups.pdns-recursor = { };

}
