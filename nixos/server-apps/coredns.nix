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
              key file "${config.age.secrets."${key}.private".path}"
            }
          ''
        else
          "";
      localZone = zone: filename: ''
        ${zone}:${LT.portStr.DNSLocal} {
          prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
          bind 127.0.0.1
          file "/nix/persistent/sync-servers/${filename}.zone" {
            reload 30s
          }
        }
      '';
      localForward = zone: dnssecKey: ''
        ${zone} {
          any
          bufsize 1232
          loadbalance round_robin
          prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}

          forward . 127.0.0.1:${LT.portStr.DNSLocal}
          ${dnssec dnssecKey}
        }
      '';
      publicZone = zone: filename: dnssecKey: ''
        ${zone} {
          ${publicZone' filename dnssecKey}
        }
      '';

      publicZone' = filename: dnssecKey: ''
        any
        bufsize 1232
        loadbalance round_robin
        prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}

        file "/nix/persistent/sync-servers/${filename}.zone" {
          reload 30s
        }
        ${dnssec dnssecKey}
      '';
    in
    pkgs.writeText "Corefile" (
      ''
        # Selfhosted Root Zone
        . {
          # Only serve internal networks to avoid being part of DNS amplification attack
          acl {
            allow net ${builtins.concatStringsSep " " LT.constants.reserved.IPv4}
            allow net ${builtins.concatStringsSep " " LT.constants.reserved.IPv6}
            drop
          }

          ${publicZone' "ltnet-scripts/zones/opennic.root" null}
        }

        # Google DNS
        .:${LT.portStr.DNSUpstream} {
          prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
          forward . tls://8.8.8.8 tls://8.8.4.4 tls://2001:4860:4860::8888 tls://2001:4860:4860::8844 {
            tls_servername dns.google
            policy sequential
            health_check 1m
          }
          cache
        }

        # DN42 Lan Tian Authoritatives
        ${localZone "lantian.dn42" "ltnet-zones/lantian.dn42"}
        ${localZone "asn.lantian.dn42" "ltnet-scripts/zones/asn.lantian.dn42"}
        ${localForward "lantian.dn42" "Klantian.dn42.+013+20109"}

        ${publicZone "184/29.76.22.172.in-addr.arpa" "ltnet-zones/184_29.76.22.172.in-addr.arpa"
          "K184_29.76.22.172.in-addr.arpa.+013+08709"
        }
        ${publicZone "96/27.76.22.172.in-addr.arpa" "ltnet-zones/96_27.76.22.172.in-addr.arpa"
          "K96_27.76.22.172.in-addr.arpa.+013+41969"
        }
        ${publicZone "d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa" "ltnet-zones/d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa"
          "Kd.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.+013+18344"
        }

        # DN42 Authoritative
        ${publicZone "dn42" "ltnet-scripts/zones/dn42" null}
        ${publicZone "20.172.in-addr.arpa" "ltnet-scripts/zones/20.172.in-addr.arpa" null}
        ${publicZone "21.172.in-addr.arpa" "ltnet-scripts/zones/21.172.in-addr.arpa" null}
        ${publicZone "22.172.in-addr.arpa" "ltnet-scripts/zones/22.172.in-addr.arpa" null}
        ${publicZone "23.172.in-addr.arpa" "ltnet-scripts/zones/23.172.in-addr.arpa" null}
        ${publicZone "d.f.ip6.arpa" "ltnet-scripts/zones/d.f.ip6.arpa" null}

        # NeoNetwork Authoritative
        ${publicZone "neo" "ltnet-scripts/zones/neo" null}
        ${publicZone "127.10.in-addr.arpa" "ltnet-scripts/zones/127.10.in-addr.arpa" null}

        # NeoNetwork Lan Tian Authoritative
        ${localZone "lantian.neo" "ltnet-zones/lantian.neo"}
        ${localZone "asn.lantian.neo" "ltnet-scripts/zones/asn.lantian.neo"}
        ${localForward "lantian.neo" "Klantian.neo.+013+47346"}

        ${publicZone "10.127.10.in-addr.arpa" "ltnet-zones/10.127.10.in-addr.arpa"
          "K10.127.10.in-addr.arpa.+013+53292"
        }
        ${publicZone "0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa" "ltnet-zones/0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa"
          "K0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.+013+11807"
        }

        # LTNET Public Facing Addressing
        ${publicZone "asn.lantian.pub" "ltnet-scripts/zones/asn.lantian.pub" "Kasn.lantian.pub.+013+48539"}

        # LTNET Authoritative
        ${publicZone "18.198.in-addr.arpa" "ltnet-zones/18.198.in-addr.arpa" null}
        ${publicZone "19.198.in-addr.arpa" "ltnet-zones/19.198.in-addr.arpa" null}

        # LTNET Active Directory
        ${publicZone "ad.lantian.pub" "ltnet-scripts/zones/ad.lantian.pub" null}
        ${publicZone "_msdcs.ad.lantian.pub" "ltnet-scripts/zones/_msdcs.ad.lantian.pub" null}

        # Public Internet Authoritative
        ${publicZone "lantian.eu.org" "ltnet-zones/lantian.eu.org" "Klantian.eu.org.+013+37106"}

        # OpenNIC Authoritative
        ${publicZone "opennic.glue" "ltnet-scripts/zones/opennic.glue" null}
        ${publicZone "dns.opennic.glue" "ltnet-scripts/zones/dns.opennic.glue" null}
        ${publicZone "bbs" "ltnet-scripts/zones/bbs" null}
        ${publicZone "chan" "ltnet-scripts/zones/chan" null}
        ${publicZone "cyb" "ltnet-scripts/zones/cyb" null}
        ${publicZone "dyn" "ltnet-scripts/zones/dyn" null}
        ${publicZone "epic" "ltnet-scripts/zones/epic" null}
        ${publicZone "fur" "ltnet-scripts/zones/fur" null}
        ${publicZone "geek" "ltnet-scripts/zones/geek" null}
        ${publicZone "gopher" "ltnet-scripts/zones/gopher" null}
        ${publicZone "indy" "ltnet-scripts/zones/indy" null}
        ${publicZone "libre" "ltnet-scripts/zones/libre" null}
        ${publicZone "null" "ltnet-scripts/zones/null" null}
        ${publicZone "o" "ltnet-scripts/zones/o" null}
        ${publicZone "oss" "ltnet-scripts/zones/oss" null}
        ${publicZone "oz" "ltnet-scripts/zones/oz" null}
        ${publicZone "parody" "ltnet-scripts/zones/parody" null}
        ${publicZone "pirate" "ltnet-scripts/zones/pirate" null}

        # Lan Tian Mobile VoLTE
        ${publicZone "mnc001.mcc001.3gppnetwork.org" "ltnet-zones/mnc001.mcc001.3gppnetwork.org" null}
        ${publicZone "mnc010.mcc315.3gppnetwork.org" "ltnet-zones/mnc010.mcc315.3gppnetwork.org" null}
        ${publicZone "mnc999.mcc999.3gppnetwork.org" "ltnet-zones/mnc999.mcc999.3gppnetwork.org" null}

        # Meshname
        meshname {
          prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
          meshname
        }

        meship {
          prometheus ${config.lantian.netns.coredns-authoritative.ipv4}:${LT.portStr.Prometheus.CoreDNS}
          meship
        }
      ''
      + (lib.optionalString config.services.iodine.server.enable ''
        # Iodine
        ${config.services.iodine.server.domain}.:53 {
          any
          bufsize 1232
          loadbalance round_robin
          forward . ${LT.this.ltnet.IPv4}:${LT.portStr.Iodine} {
            prefer_udp
            max_fails 0
          }
        }
      '')
    );
in
lib.mkIf (!(LT.this.hasTag LT.tags.low-ram)) {
  age.secrets = builtins.listToAttrs (
    lib.flatten (
      builtins.map (n: [
        {
          name = "${n}.key";
          value = {
            name = "${n}.key";
            owner = "coredns";
            group = "coredns";
            file = inputs.secrets + "/dnssec/${n}.key.age";
          };
        }
        {
          name = "${n}.private";
          value = {
            name = "${n}.private";
            owner = "coredns";
            group = "coredns";
            file = inputs.secrets + "/dnssec/${n}.private.age";
          };
        }
      ]) (import (inputs.secrets + "/dnssec.nix"))
    )
  );

  lantian.netns.coredns-authoritative = {
    ipSuffix = "54";
    inherit (config.services.coredns) enable;
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

  systemd.services = {
    coredns-authoritative = netns.bind {
      description = "Coredns for authoritative zones";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = LT.serviceHarden // {
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        ExecStart = "${pkgs.nur-xddxdd.lantianCustomized.coredns}/bin/coredns -conf=${corednsConfig}";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
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
  };

  users.users.coredns = {
    group = "coredns";
    isSystemUser = true;
  };
  users.groups.coredns = { };
}
