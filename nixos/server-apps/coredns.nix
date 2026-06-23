{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  netns = config.lantian.netns.coredns-authoritative;

  corednsConfig =
    let
      dnssec =
        key:
        if key != null then
          ''
            dnssec {
              key file "${config.sops.secrets."${key}.private".path}"
            }
          ''
        else
          "";
      forwardZone = zone: dnssecKey: ''
        ${zone} {
          any
          bufsize 1232
          loadbalance round_robin
          prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
          forward . 127.0.0.1:${LT.portStr.DNSLocal}
          ${dnssec dnssecKey}
        }
      '';
    in
    pkgs.writeText "Corefile" ''
      # Selfhosted Root Zone
      . {
        # Only serve internal networks to avoid being part of DNS amplification attack
        acl {
          allow net ${builtins.concatStringsSep " " LT.constants.reserved.IPv4}
          allow net ${builtins.concatStringsSep " " LT.constants.reserved.IPv6}
          drop
        }
        any
        bufsize 1232
        loadbalance round_robin
        forward . 127.0.0.1:${LT.portStr.DNSLocal}
        ${dnssec null}
      }

      # DN42 Lan Tian Authoritatives
      ${forwardZone "lantian.dn42" "Klantian.dn42.+013+20109"}
      ${forwardZone "asn.lantian.dn42" null}
      ${forwardZone "184/29.76.22.172.in-addr.arpa" "K184_29.76.22.172.in-addr.arpa.+013+08709"}
      ${forwardZone "96/27.76.22.172.in-addr.arpa" "K96_27.76.22.172.in-addr.arpa.+013+41969"}
      ${forwardZone "d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa" "Kd.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.+013+18344"}
      ${forwardZone "7.4.5.2.4.2.4.0.tel.dn42" "K7.4.5.2.4.2.4.0.tel.dn42.+013+33346"}

      # LTNET Active Directory
      ${forwardZone "ad.lantian.pub" null}

      # NeoNetwork Lan Tian Authoritative
      ${forwardZone "lantian.neo" "Klantian.neo.+013+47346"}
      ${forwardZone "asn.lantian.neo" null}
      ${forwardZone "10.127.10.in-addr.arpa" "K10.127.10.in-addr.arpa.+013+53292"}
      ${forwardZone "0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa" "K0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.+013+11807"}

      # LTNET Public Facing Addressing
      ${forwardZone "asn.lantian.pub" "Kasn.lantian.pub.+013+48539"}

      # LTNET Authoritative
      ${forwardZone "18.198.in-addr.arpa" null}
      ${forwardZone "19.198.in-addr.arpa" null}

      # Public Internet Authoritative
      ${forwardZone "lantian.eu.org" "Klantian.eu.org.+013+37106"}

      # NeoNetwork Authoritative
      ${forwardZone "neo" null}
      ${forwardZone "127.10.in-addr.arpa" null}

      # Lan Tian Mobile VoLTE
      ${forwardZone "mnc001.mcc001.3gppnetwork.org" null}
      ${forwardZone "mnc010.mcc315.3gppnetwork.org" null}
      ${forwardZone "mnc999.mcc999.3gppnetwork.org" null}

      # Meshname
      meshname {
        prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
        meshname
      }

      meship {
        prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
        meship
      }
    '';

in
lib.mkIf (!(LT.this.hasTag LT.tags.low-ram)) {
  sops.secrets =
    let
      lines = lib.splitString "\n" (builtins.readFile (inputs.secrets + "/common/dnssec.yaml"));
      keyNames = builtins.map (l: lib.trim (builtins.head (lib.splitString ":" l))) (
        builtins.filter (lib.hasPrefix "    K") lines
      );
    in
    lib.genAttrs keyNames (n: {
      sopsFile = inputs.secrets + "/common/dnssec.yaml";
      key = "dnssec/${n}";
      owner = "coredns";
      group = "coredns";
    });

  lantian.netns.coredns-authoritative = {
    ipSuffix = "54";
    announcedIPv4 = [
      "172.22.76.109"
      "198.19.0.254"
      "10.127.10.254"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::54"
      "fd10:127:10:2547::54"
    ];
    birdBindTo = [ "coredns-authoritative.service" ];
  };

  services.knot =
    let
      mkDn42Zone = name: {
        domain = name;
        storage = "/var/cache/zones/";
        file = "${name}.zone";
        refresh-min-interval = "1m";
        refresh-max-interval = "1d";
        master = "dn42";
        acl = [
          "dn42_notify"
          "allow_transfer"
        ];
      };
      mkOpennicZone = name: {
        domain = name;
        storage = "/var/cache/zones/";
        file = "${if name == "." then "root" else name}.zone";
        refresh-min-interval = "1h";
        refresh-max-interval = "1d";
        master = "opennic";
        acl = [
          "opennic_notify"
          "allow_transfer"
        ];
      };
      mkLtnetAdZone = name: {
        domain = name;
        storage = "/var/cache/zones/";
        file = "${if name == "." then "root" else name}.zone";
        refresh-min-interval = "1h";
        refresh-max-interval = "1d";
        master = "ltnet_ad";
        acl = [
          "ltnet_ad_notify"
          "allow_transfer"
        ];
      };
      mkLocalZone = domain: path: {
        inherit domain;
        file = "${builtins.baseNameOf path}.zone";
        storage = "/nix/sync-servers/${builtins.dirOf path}";
      };
    in
    {
      enable = true;
      checkConfig = false;
      settings = {
        server = {
          listen = [
            "127.0.0.1@${LT.portStr.DNSLocal}"
            "::1@${LT.portStr.DNSLocal}"
          ];
          identity = "lantian";
          version = "2.3.3";
          nsid = "lantian";
          edns-client-subnet = true;
          answer-rotation = true;
        };

        log = [
          {
            target = "stdout";
            server = "warning";
            control = "warning";
            zone = "info";
            quic = "warning";
          }
        ];

        remote = [
          {
            id = "dn42";
            via = [
              config.lantian.netns.coredns-authoritative.ipv4
              config.lantian.netns.coredns-authoritative.ipv6
            ];
            address = [
              "fd42:180:3de0:30::1@${LT.portStr.DNS}"
              "fd42:180:3de0:10:5054:ff:fe87:ea39@${LT.portStr.DNS}"
            ];
          }
          {
            id = "opennic";
            via = [
              config.lantian.netns.coredns-authoritative.ipv4
              config.lantian.netns.coredns-authoritative.ipv6
            ];
            address = [
              "161.97.219.84@${LT.portStr.DNS}"
              "94.103.153.176@${LT.portStr.DNS}"
              "178.63.116.152@${LT.portStr.DNS}"
              "188.226.146.136@${LT.portStr.DNS}"
              "144.76.103.143@${LT.portStr.DNS}"
              "2001:470:4212:10:0:100:53:10@${LT.portStr.DNS}"
              "2a02:990:219:1:ba:1337:cafe:3@${LT.portStr.DNS}"
              "2a01:4f8:141:4281::999@${LT.portStr.DNS}"
              "2a03:b0c0:0:1010::13f:6001@${LT.portStr.DNS}"
              "2a01:4f8:192:43a5::2@${LT.portStr.DNS}"
            ];
          }
          {
            id = "ltnet_ad";
            via = [
              config.lantian.netns.coredns-authoritative.ipv4
              config.lantian.netns.coredns-authoritative.ipv6
            ];
            address = [
              "198.18.0.202@${LT.portStr.DNS}"
              "fdbc:f9dc:67ad::202@${LT.portStr.DNS}"
            ];
          }
        ];

        acl = [
          {
            id = "dn42_notify";
            action = "notify";
            address = [
              "fd42:180:3de0:30::1"
              "fd42:180:3de0:10:5054:ff:fe87:ea39"
            ];
          }
          {
            id = "opennic_notify";
            action = "notify";
            address = [
              "161.97.219.84"
              "94.103.153.176"
              "178.63.116.152"
              "188.226.146.136"
              "144.76.103.143"
              "2001:470:4212:10:0:100:53:10"
              "2a02:990:219:1:ba:1337:cafe:3"
              "2a01:4f8:141:4281::999"
              "2a03:b0c0:0:1010::13f:6001"
              "2a01:4f8:192:43a5::2"
            ];
          }
          {
            id = "ltnet_ad_notify";
            action = "notify";
            address = [
              "198.18.0.202"
              "fdbc:f9dc:67ad::202"
            ];
          }
          {
            id = "allow_transfer";
            action = "transfer";
            address = [
              "0.0.0.0/0"
              "::/0"
            ];
          }
        ];

        zone =
          (map mkDn42Zone LT.constants.zones.DN42)
          ++ (map mkOpennicZone ([ "." ] ++ LT.constants.zones.OpenNIC))
          ++ (map mkLtnetAdZone [
            "ad.lantian.pub"
            "_msdcs.ad.lantian.pub"
          ])
          ++ (map (z: mkLocalZone z.domain z.path) [
            {
              domain = "lantian.dn42";
              path = "ltnet-zones/lantian.dn42";
            }
            {
              domain = "asn.lantian.dn42";
              path = "ltnet-scripts/zones/asn.lantian.dn42";
            }
            {
              domain = "184/29.76.22.172.in-addr.arpa";
              path = "ltnet-zones/184_29.76.22.172.in-addr.arpa";
            }
            {
              domain = "96/27.76.22.172.in-addr.arpa";
              path = "ltnet-zones/96_27.76.22.172.in-addr.arpa";
            }
            {
              domain = "d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa";
              path = "ltnet-zones/d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa";
            }
            {
              domain = "7.4.5.2.4.2.4.0.tel.dn42";
              path = "ltnet-zones/7.4.5.2.4.2.4.0.tel.dn42";
            }
            {
              domain = "lantian.neo";
              path = "ltnet-zones/lantian.neo";
            }
            {
              domain = "asn.lantian.neo";
              path = "ltnet-scripts/zones/asn.lantian.neo";
            }
            {
              domain = "10.127.10.in-addr.arpa";
              path = "ltnet-zones/10.127.10.in-addr.arpa";
            }
            {
              domain = "0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa";
              path = "ltnet-zones/0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa";
            }
            {
              domain = "asn.lantian.pub";
              path = "ltnet-scripts/zones/asn.lantian.pub";
            }
            {
              domain = "18.198.in-addr.arpa";
              path = "ltnet-zones/18.198.in-addr.arpa";
            }
            {
              domain = "19.198.in-addr.arpa";
              path = "ltnet-zones/19.198.in-addr.arpa";
            }
            {
              domain = "lantian.eu.org";
              path = "ltnet-zones/lantian.eu.org";
            }
            {
              domain = "neo";
              path = "ltnet-scripts/zones/neo";
            }
            {
              domain = "127.10.in-addr.arpa";
              path = "ltnet-scripts/zones/127.10.in-addr.arpa";
            }
            {
              domain = "mnc001.mcc001.3gppnetwork.org";
              path = "ltnet-zones/mnc001.mcc001.3gppnetwork.org";
            }
            {
              domain = "mnc010.mcc315.3gppnetwork.org";
              path = "ltnet-zones/mnc010.mcc315.3gppnetwork.org";
            }
            {
              domain = "mnc999.mcc999.3gppnetwork.org";
              path = "ltnet-zones/mnc999.mcc999.3gppnetwork.org";
            }
          ]);
      };
    };

  services.prometheus.exporters.knot = {
    enable = true;
    port = LT.port.Prometheus.KnotExporter;
    listenAddress = LT.this.ltnet.IPv4;
  };

  systemd.services = {
    coredns-authoritative = netns.bind {
      description = "Coredns for authoritative zones";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = LT.serviceHarden // {
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        MemoryMax = "256M";
        MemorySwapMax = "64M";

        ExecStart = "${lib.getExe pkgs.nur-xddxdd.lantianCustomized.coredns} -conf=${corednsConfig}";
        ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -SIGUSR1 $MAINPID";
        Restart = "on-failure";

        User = "coredns";
        Group = "coredns";
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
      };
    };

    knot = netns.bind {
      serviceConfig = {
        ReadWritePaths = [ "/tmp" ];
        CacheDirectory = "zones";
      };
    };
  };

  users.users.coredns = {
    group = "coredns";
    isSystemUser = true;
  };
  users.groups.coredns = { };
}
