{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
  hostPkgs = pkgs;
  hostConfig = config;
  corednsContainerIP = 54;
  knotContainerIP = 55;

  dnssecKeys = import ../../dnssec-keys.nix;
in
{
  age.secrets = builtins.listToAttrs (pkgs.lib.flatten (builtins.map
    (n: [
      {
        name = "${n}.key";
        value = {
          name = "${n}.key";
          file = ../../secrets/dnssec + "/${n}.key.age";
        };
      }
      {
        name = "${n}.private";
        value = {
          name = "${n}.private";
          file = ../../secrets/dnssec + "/${n}.private.age";
        };
      }
    ])
    dnssecKeys));
} //
{
  containers.coredns = {
    autoStart = true;
    ephemeral = true;

    bindMounts = {
      "/var/lib" = { hostPath = "/var/lib"; isReadOnly = false; };
      "/run/secrets" = { hostPath = "/run/secrets"; isReadOnly = true; };
    };

    forwardPorts = [
      { hostPort = 53; containerPort = 53; protocol = "tcp"; }
      { hostPort = 53; containerPort = 53; protocol = "udp"; }
    ];

    privateNetwork = true;
    hostBridge = "ltnet";
    localAddress = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString corednsContainerIP}/24";
    localAddress6 = "${thisHost.ltnet.IPv6Prefix}::${builtins.toString corednsContainerIP}/64";

    config = { config, pkgs, ... }: {
      system.stateVersion = "21.05";
      nixpkgs.pkgs = hostPkgs;
      networking.hostName = hostConfig.networking.hostName;
      networking.defaultGateway = "${thisHost.ltnet.IPv4Prefix}.1";
      networking.defaultGateway6 = "${thisHost.ltnet.IPv6Prefix}::1";
      networking.firewall.enable = false;
      services.journald.extraConfig = ''
        SystemMaxUse=50M
        SystemMaxFileSize=10M
      '';

      services.coredns = {
        enable = true;
        package = pkgs.nur.repos.xddxdd.coredns;
        config = ''
          # Selfhosted Root Zone
          . {
            any
            bufsize 1232
            loadbalance round_robin

            forward . ${thisHost.ltnet.IPv4Prefix}.55 ${thisHost.ltnet.IPv6Prefix}::55
          }

          # Google DNS
          .:55 {
            forward . tls://8.8.8.8 tls://8.8.4.4 tls://2001:4860:4860::8888 tls://2001:4860:4860::8844 {
              tls_servername dns.google
              policy sequential
              health_check 1m
            }
            cache
          }

          # NextDNS.io
          .:56 {
            forward . tls://45.90.28.61 tls://45.90.30.61 tls://2a07:a8c0::37:8897 tls://2a07:a8c1::37:8897 {
              tls_servername ${config.networking.hostName}-378897.dns.nextdns.io
              policy sequential
              health_check 1m
            }
            cache
          }

          # DN42 Lan Tian Authoritatives
          lantian.dn42:54 {
            bind 127.0.0.1
            file "/var/lib/zones/zones/lantian.dn42.zone"
          }
          _acme-challenge.lantian.dn42:54 {
            bind 127.0.0.1
            forward . 172.18.10.56
          }
          asn.lantian.dn42:54 {
            bind 127.0.0.1
            file "/var/lib/zones/zones-ltnet/asn.lantian.dn42.zone"
          }
          lantian.dn42 {
            any
            bufsize 1232
            loadbalance round_robin

            forward . 127.0.0.1:54
            dnssec {
              key file "${hostConfig.age.secrets."Klantian.dn42.+013+20109.private".path}"
            }
          }

          184/29.76.22.172.in-addr.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/184_29.76.22.172.in-addr.arpa.zone"
            dnssec {
              key file "${hostConfig.age.secrets."K184_29.76.22.172.in-addr.arpa.+013+08709.private".path}"
            }
          }
          96/27.76.22.172.in-addr.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/96_27.76.22.172.in-addr.arpa.zone"
            dnssec {
              key file "${hostConfig.age.secrets."K96_27.76.22.172.in-addr.arpa.+013+41969.private".path}"
            }
          }
          d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.zone"
            dnssec {
              key file "${hostConfig.age.secrets."Kd.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.+013+18344.private".path}"
            }
          }

          # NeoNetwork Authoritative
          neo {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones-ltnet/neo.zone"
          }
          127.10.in-addr.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones-ltnet/127.10.in-addr.arpa.zone"
          }

          # NeoNetwork Lan Tian Authoritative
          lantian.neo:54 {
            bind 127.0.0.1
            file "/var/lib/zones/zones/lantian.neo.zone"
          }
          _acme-challenge.lantian.neo:54 {
            bind 127.0.0.1
            forward . 172.18.10.56
          }
          asn.lantian.neo:54 {
            bind 127.0.0.1
            file "/var/lib/zones/zones-ltnet/asn.lantian.neo.zone"
          }
          lantian.neo {
            any
            bufsize 1232
            loadbalance round_robin

            forward . 127.0.0.1:54
            dnssec {
              key file "${hostConfig.age.secrets."Klantian.neo.+013+47346.private".path}"
            }
          }

          10.127.10.in-addr.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/10.127.10.in-addr.arpa.zone"
            dnssec {
              key file "${hostConfig.age.secrets."K10.127.10.in-addr.arpa.+013+53292.private".path}"
            }
          }
          0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.zone"
            dnssec {
              key file "${hostConfig.age.secrets."K0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.+013+11807.private".path}"
            }
          }

          # LTNET Public Facing Addressing
          asn.lantian.pub {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones-ltnet/asn.lantian.pub.zone"
            dnssec {
              key file "${hostConfig.age.secrets."Kasn.lantian.pub.+013+48539.private".path}"
            }
          }
          dn42.lantian.pub {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/dn42.lantian.pub.zone"
            dnssec {
              key file "${hostConfig.age.secrets."Kdn42.lantian.pub.+013+58078.private".path}"
            }
          }
          neo.lantian.pub {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/neo.lantian.pub.zone"
            dnssec {
              key file "${hostConfig.age.secrets."Kneo.lantian.pub.+013+53977.private".path}"
            }
          }
          zt.lantian.pub {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/zt.lantian.pub.zone"
            dnssec {
              key file "${hostConfig.age.secrets."Kzt.lantian.pub.+013+44508.private".path}"
            }
          }

          # LTNET Authoritative
          18.172.in-addr.arpa {
            any
            bufsize 1232
            loadbalance round_robin

            file "/var/lib/zones/zones/18.172.in-addr.arpa.zone"
          }

          # Public Internet Authoritative
          lantian.eu.org:54 {
            bind 127.0.0.1
            file "/var/lib/zones/zones/lantian.eu.org.zone"
          }
          _acme-challenge.lantian.eu.org:54 {
            bind 127.0.0.1
            forward . 172.18.10.56
          }
          lantian.eu.org {
            any
            bufsize 1232
            loadbalance round_robin

            forward . 127.0.0.1:54
            dnssec {
              key file "${hostConfig.age.secrets."Klantian.eu.org.+013+37106.private".path}"
            }
          }
        '';
      };

      systemd.services.coredns.serviceConfig = {
        DynamicUser = pkgs.lib.mkForce false;
        User = "root";
      };

      services.bird2 = {
        enable = true;
        checkConfig = false;
        config = ''
          log stderr { error, fatal };
          protocol device {}

          protocol ospf {
            ipv4 {
              import none;
              export all;
            };
            area 0.0.0.0 {
              interface "*" {
                type broadcast;
                cost 1;
                hello 2;
                retransmit 2;
                dead count 2;
              };
            };
          }

          protocol ospf v3 {
            ipv6 {
              import none;
              export all;
            };
            area 0.0.0.0 {
              interface "*" {
                type broadcast;
                cost 1;
                hello 2;
                retransmit 2;
                dead count 2;
              };
            };
          }

          protocol static {
            ipv4;
            route 172.22.76.109/32 unreachable;
            route 172.18.0.254/32 unreachable;
            route 10.127.10.254/32 unreachable;
          }

          protocol static {
            ipv6;
            route fdbc:f9dc:67ad:2547::54/128 unreachable;
            route fd10:127:10:2547::54/128 unreachable;
          }
        '';
      };

      services.resolved.enable = false;

      systemd.network.enable = true;
      systemd.network.netdevs.dummy0 = {
        netdevConfig = {
          Kind = "dummy";
          Name = "dummy0";
        };
      };

      systemd.network.networks.dummy0 = {
        matchConfig = {
          Name = "dummy0";
        };

        networkConfig = {
          IPv6PrivacyExtensions = false;
        };

        addresses = [
          { addressConfig = { Address = "172.22.76.109/32"; }; }
          { addressConfig = { Address = "172.18.0.254/32"; }; }
          { addressConfig = { Address = "10.127.10.254/32"; }; }
          { addressConfig = { Address = "fdbc:f9dc:67ad:2547::54/128"; }; }
          { addressConfig = { Address = "fd10:127:10:2547::54/128"; }; }
        ];
      };
    };
  };

  containers.coredns-knot = {
    autoStart = true;
    ephemeral = true;

    bindMounts = {
      "/var/lib" = { hostPath = "/var/lib"; isReadOnly = false; };
    };

    privateNetwork = true;
    hostBridge = "ltnet";
    localAddress = "${thisHost.ltnet.IPv4Prefix}.${builtins.toString knotContainerIP}/24";
    localAddress6 = "${thisHost.ltnet.IPv6Prefix}::${builtins.toString knotContainerIP}/64";

    config = { config, pkgs, ... }: {
      system.stateVersion = "21.05";
      nixpkgs.pkgs = hostPkgs;
      networking.hostName = hostConfig.networking.hostName;
      networking.defaultGateway = "${thisHost.ltnet.IPv4Prefix}.1";
      networking.defaultGateway6 = "${thisHost.ltnet.IPv6Prefix}::1";
      networking.firewall.enable = false;
      services.journald.extraConfig = ''
        SystemMaxUse=50M
        SystemMaxFileSize=10M
      '';

      services.knot = {
        enable = true;
        extraConfig =
          let
            dn42SlaveZone = name: ''
              - domain: ${name}
                storage: /var/lib/zones/zones-slave/
                file: ${name}.zone
                refresh-min-interval: 1m
                refresh-max-interval: 1d
                master: dn42
                acl: dn42_notify
                acl: allow_transfer
            '';
            opennicSlaveZone = name: ''
              - domain: ${name}
                storage: /var/lib/zones/zones-slave/
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
              listen: 0.0.0.0@53
              listen: ::@53
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
              via: ${thisHost.ltnet.IPv4Prefix}.${builtins.toString knotContainerIP}
              via: ${thisHost.ltnet.IPv6Prefix}::${builtins.toString knotContainerIP}

              # {b,j}.master.delegation-servers.dn42
              address: fd42:180:3de0:30::1@53
              address: fd42:180:3de0:10:5054:ff:fe87:ea39@53

              # {b,j,k}.delegation-servers.dn42
              # address: 172.20.129.1@53
              # address: fd42:4242:2601:ac53::1@53
              # address: 172.20.1.254@53
              # address: fd42:5d71:219:0:216:3eff:fe1e:22d6@53
              # address: 172.20.14.34@53
              # address: fdcf:8538:9ad5:1111::2@53

            - id: opennic
              via: ${thisHost.ltnet.IPv4Prefix}.${builtins.toString knotContainerIP}
              via: ${thisHost.ltnet.IPv6Prefix}::${builtins.toString knotContainerIP}
              address: 161.97.219.84@53
              address: 94.103.153.176@53
              address: 178.63.116.152@53
              address: 188.226.146.136@53
              address: 144.76.103.143@53
              address: 2001:470:4212:10:0:100:53:10@53
              address: 2a02:990:219:1:ba:1337:cafe:3@53
              address: 2a01:4f8:141:4281::999@53
              address: 2a03:b0c0:0:1010::13f:6001@53
              address: 2a01:4f8:192:43a5::2@53

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
          + (pkgs.lib.concatStringsSep "\n" (builtins.map dn42SlaveZone [
            "dn42"
            "10.in-addr.arpa"
            "20.172.in-addr.arpa"
            "21.172.in-addr.arpa"
            "22.172.in-addr.arpa"
            "23.172.in-addr.arpa"
            "31.172.in-addr.arpa"
            "d.f.ip6.arpa"
          ]))
          + (pkgs.lib.concatStringsSep "\n" (builtins.map opennicSlaveZone [
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

      systemd.services.knot.serviceConfig = {
        User = pkgs.lib.mkForce "root";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /run/secrets 755 root root"
  ];
}
