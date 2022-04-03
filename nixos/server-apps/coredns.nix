{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  corednsNetns = LT.netns {
    name = "coredns";
    enable = config.services.coredns.enable;
    announcedIPv4 = [
      "172.22.76.109"
      "172.18.0.254"
      "10.127.10.254"
    ];
    announcedIPv6 = [
      "fdbc:f9dc:67ad:2547::54"
      "fd10:127:10:2547::54"
    ];
    birdBindTo = [ "coredns.service" ];
  };
  corednsKnotNetns = LT.netns {
    name = "coredns-knot";
    enable = config.services.knot.enable;
    birdBindTo = [ "knot.service" ];
  };
in
{
  age.secrets = lib.mkIf (config.services.coredns.enable || config.services.knot.enable)
    (builtins.listToAttrs (lib.flatten (builtins.map
      (n: [
        {
          name = "${n}.key";
          value = {
            name = "${n}.key";
            owner = "container";
            group = "container";
            file = pkgs.secrets + "/dnssec/${n}.key.age";
          };
        }
        {
          name = "${n}.private";
          value = {
            name = "${n}.private";
            owner = "container";
            group = "container";
            file = pkgs.secrets + "/dnssec/${n}.private.age";
          };
        }
      ])
      LT.dnssecKeys)));

  services.coredns = {
    enable = true;
    package = pkgs.coredns;
    config =
      let
        dnssec = key:
          if key != null then ''
            dnssec {
              key file "${config.age.secrets."${key}.private".path}"
            }
          '' else "";
        localZone = zone: filename: ''
          ${zone}:${LT.portStr.DNSLocal} {
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

            forward . 127.0.0.1:${LT.portStr.DNSLocal}
            ${dnssec dnssecKey}
          }
        '';
        publicZone = zone: filename: dnssecKey: ''
          ${zone} {
            any
            bufsize 1232
            loadbalance round_robin

            file "/nix/persistent/sync-servers/${filename}.zone" {
              reload 30s
            }
            ${dnssec dnssecKey}
          }
        '';

      in
      ''
        # Selfhosted Root Zone
        . {
          any
          bufsize 1232
          loadbalance round_robin

          forward . ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.coredns-knot} ${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.coredns-knot}
          ${dnssec null}
        }

        # Google DNS
        .:${LT.portStr.DNSUpstream} {
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

        ${publicZone "184/29.76.22.172.in-addr.arpa" "ltnet-zones/184_29.76.22.172.in-addr.arpa" "K184_29.76.22.172.in-addr.arpa.+013+08709"}
        ${publicZone "96/27.76.22.172.in-addr.arpa" "ltnet-zones/96_27.76.22.172.in-addr.arpa" "K96_27.76.22.172.in-addr.arpa.+013+41969"}
        ${publicZone "d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa" "ltnet-zones/d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa" "Kd.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.+013+18344"}

        # NeoNetwork Authoritative
        ${publicZone "neo" "ltnet-scripts/zones/neo" null}
        ${publicZone "127.10.in-addr.arpa" "ltnet-scripts/zones/127.10.in-addr.arpa" null}

        # NeoNetwork Lan Tian Authoritative
        ${localZone "lantian.neo" "ltnet-zones/lantian.neo"}
        ${localZone "asn.lantian.neo" "ltnet-scripts/zones/asn.lantian.neo"}
        ${localForward "lantian.neo" "Klantian.neo.+013+47346"}

        ${publicZone "10.127.10.in-addr.arpa" "ltnet-zones/10.127.10.in-addr.arpa" "K10.127.10.in-addr.arpa.+013+53292"}
        ${publicZone "0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa" "ltnet-zones/0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa" "K0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.+013+11807"}

        # LTNET Public Facing Addressing
        ${publicZone "asn.lantian.pub" "ltnet-scripts/zones/asn.lantian.pub" "Kasn.lantian.pub.+013+48539"}

        # LTNET Authoritative
        ${publicZone "18.172.in-addr.arpa" "ltnet-zones/18.172.in-addr.arpa" null}

        # Public Internet Authoritative
        ${publicZone "lantian.eu.org" "ltnet-zones/lantian.eu.org" "Klantian.eu.org.+013+37106"}
      '';
  };

  services.knot = {
    enable = true;
    extraConfig =
      let
        dn42SlaveZone = name: ''
          - domain: ${name}
            storage: /var/cache/zones/
            file: ${name}.zone
            refresh-min-interval: 1m
            refresh-max-interval: 1d
            master: dn42
            acl: dn42_notify
            acl: allow_transfer
        '';
        opennicSlaveZone = name: ''
          - domain: ${name}
            storage: /var/cache/zones/
            file: ${if name == "." then "root" else name}.zone
            refresh-min-interval: 1h
            refresh-max-interval: 1d
            master: opennic
            acl: opennic_notify
            acl: allow_transfer
        '';
      in
      ''
        server:
          listen: 0.0.0.0@${LT.portStr.DNS}
          listen: ::@${LT.portStr.DNS}
          identity: lantian
          version: 2.3.3
          nsid: lantian
          edns-client-subnet: on
          answer-rotation: on

        log:
        - target: stdout
          any: info

        remote:
        - id: dn42
          via: ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.coredns-knot}
          via: ${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.coredns-knot}

          # {b,j}.master.delegation-servers.dn42
          address: fd42:180:3de0:30::1@${LT.portStr.DNS}
          address: fd42:180:3de0:10:5054:ff:fe87:ea39@${LT.portStr.DNS}

          # {b,j,k}.delegation-servers.dn42
          # address: 172.20.129.1@${LT.portStr.DNS}
          # address: fd42:4242:2601:ac53::1@${LT.portStr.DNS}
          # address: 172.20.1.254@${LT.portStr.DNS}
          # address: fd42:5d71:219:0:216:3eff:fe1e:22d6@${LT.portStr.DNS}
          # address: 172.20.14.34@${LT.portStr.DNS}
          # address: fdcf:8538:9ad5:1111::2@${LT.portStr.DNS}

        - id: opennic
          via: ${LT.this.ltnet.IPv4Prefix}.${LT.containerIP.coredns-knot}
          via: ${LT.this.ltnet.IPv6Prefix}::${LT.containerIP.coredns-knot}
          address: 161.97.219.84@${LT.portStr.DNS}
          address: 94.103.153.176@${LT.portStr.DNS}
          address: 178.63.116.152@${LT.portStr.DNS}
          address: 188.226.146.136@${LT.portStr.DNS}
          address: 144.76.103.143@${LT.portStr.DNS}
          address: 2001:470:4212:10:0:100:53:10@${LT.portStr.DNS}
          address: 2a02:990:219:1:ba:1337:cafe:3@${LT.portStr.DNS}
          address: 2a01:4f8:141:4281::999@${LT.portStr.DNS}
          address: 2a03:b0c0:0:1010::13f:6001@${LT.portStr.DNS}
          address: 2a01:4f8:192:43a5::2@${LT.portStr.DNS}

        acl:
        - id: dn42_notify
          action: notify
          # {b,j}.master.delegation-servers.dn42
          address: fd42:180:3de0:30::1
          address: fd42:180:3de0:10:5054:ff:fe87:ea39

          # {b,j,k}.delegation-servers.dn42
          #address: 172.20.129.1
          #address: fd42:4242:2601:ac53::1
          #address: 172.20.1.254
          #address: fd42:5d71:219:0:216:3eff:fe1e:22d6
          #address: 172.20.14.34
          #address: fdcf:8538:9ad5:1111::2

        - id: opennic_notify
          action: notify
          address: 161.97.219.84
          address: 94.103.153.176
          address: 178.63.116.152
          address: 188.226.146.136
          address: 144.76.103.143
          address: 2001:470:4212:10:0:100:53:10
          address: 2a02:990:219:1:ba:1337:cafe:3
          address: 2a01:4f8:141:4281::999
          address: 2a03:b0c0:0:1010::13f:6001
          address: 2a01:4f8:192:43a5::2

        - id: allow_transfer
          action: transfer
          address: 0.0.0.0/0
          address: ::/0

        zone:
      ''
      + (lib.concatStringsSep "\n" (builtins.map dn42SlaveZone [
        "dn42"
        "10.in-addr.arpa"
        "20.172.in-addr.arpa"
        "21.172.in-addr.arpa"
        "22.172.in-addr.arpa"
        "23.172.in-addr.arpa"
        "31.172.in-addr.arpa"
        "d.f.ip6.arpa"
      ]))
      + (lib.concatStringsSep "\n" (builtins.map opennicSlaveZone [
        "."
        "opennic.glue"
        "dns.opennic.glue"
        "bbs"
        "chan"
        "cyb"
        "dyn"
        "epic"
        "fur"
        "geek"
        "gopher"
        "indy"
        "libre"
        "null"
        "o"
        "oss"
        "oz"
        "parody"
        "pirate"
      ]));
  };

  systemd.services = corednsNetns.setup // corednsKnotNetns.setup // {
    coredns = corednsNetns.bind {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "container";
        Group = lib.mkForce "container";
      };
    };
    knot = corednsKnotNetns.bind {
      serviceConfig = {
        User = lib.mkForce "container";
        Group = lib.mkForce "container";

        ReadWritePaths = [ "/tmp" ];
        CacheDirectory = "zones";
      };
    };
  };

  systemd.tmpfiles.rules = lib.mkIf (config.services.coredns.enable || config.services.knot.enable) [
    "d /var/lib/zones 755 container container"
  ];
}
