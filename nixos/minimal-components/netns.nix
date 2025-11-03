{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  netnsOptions =
    { name, config, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        enableBird = lib.mkOption {
          type = lib.types.bool;
          default = (builtins.length (config.announcedIPv4 ++ config.announcedIPv6)) > 0;
        };
        overrideRoutingTable = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
        };

        # Networking
        ipSuffix = lib.mkOption { type = lib.types.str; };
        ipv4 = lib.mkOption {
          readOnly = true;
          default = "${ltnet.IPv4Prefix}.${config.ipSuffix}";
        };
        ipv6 = lib.mkOption {
          readOnly = true;
          default = "${ltnet.IPv6Prefix}::${config.ipSuffix}";
        };

        # IP announcements
        announcedIPv4 = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        announcedIPv6 = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        birdBindTo = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        # Helper functions
        bind = lib.mkOption {
          # type = lib.types.anything;
          readOnly = true;
          default =
            attr:
            if config.enable then
              (
                {
                  after = (attr.after or [ ]) ++ [ "netns-instance-${name}.service" ];
                  bindsTo = (attr.bindsTo or [ ]) ++ [ "netns-instance-${name}.service" ];
                  serviceConfig = (attr.serviceConfig or { }) // {
                    NetworkNamespacePath = "/run/netns/${name}";
                  };
                }
                // (builtins.removeAttrs attr [
                  "after"
                  "bindsTo"
                  "serviceConfig"
                ])
              )
            else
              attr;
        };
        bindExisting = lib.mkOption {
          readOnly = true;
          default =
            if config.enable then
              {
                after = [ "netns-instance-${name}.service" ];
                bindsTo = [ "netns-instance-${name}.service" ];
                serviceConfig = {
                  NetworkNamespacePath = "/run/netns/${name}";
                };
              }
            else
              { };
        };
      };
    };

  inherit (LT.this) ltnet;
in
{
  options.lantian.netns = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule netnsOptions);
    default = { };
    description = "Extra network namespaces";
  };

  config = {
    systemd.services = builtins.listToAttrs (
      lib.flatten (
        lib.mapAttrsToList (
          name: value:
          let
            interface = builtins.substring 0 12 name;
            ipns = "ip netns exec ${name} ip";
            sysctl = "ip netns exec ${name} sysctl";

            overrideRoutingTableCommands =
              op:
              lib.optionalString (value.overrideRoutingTable != null) ''
                ip rule ${op} iif ns-tnl-buyvm lookup ${builtins.toString value.overrideRoutingTable}
                ip -6 rule ${op} iif ns-tnl-buyvm lookup ${builtins.toString value.overrideRoutingTable}
                ${lib.concatMapStringsSep "\n" (
                  route: "ip rule ${op} iif ns-tnl-buyvm to ${route} lookup main"
                ) LT.constants.reserved.IPv4}
                ${lib.concatMapStringsSep "\n" (
                  route: "ip -6 rule ${op} iif ns-tnl-buyvm to ${route} lookup main"
                ) LT.constants.reserved.IPv6}
              '';

            birdConfig = pkgs.writeText "bird-netns-${name}.conf" (
              ''
                log stderr { error, fatal };
                router id ${value.ipv4};
                protocol device {}

                protocol babel {
                  ipv4 {
                    import none;
                    export all;
                  };
                  ipv6 {
                    import none;
                    export all;
                  };
                  interface "eth*" {
                    type wired;
                    hello interval 1s;
                    update interval 1s;
                    port 6695;
                  };
                }

                protocol static {
                  ipv4;
              ''
              + (lib.concatStrings (
                builtins.map (ip: ''
                  route ${ip}/32 unreachable;
                '') value.announcedIPv4
              ))
              + ''
                }

                protocol static {
                  ipv6;
              ''
              + (lib.concatStrings (
                builtins.map (ip: ''
                  route ${ip}/128 unreachable;
                '') value.announcedIPv6
              ))
              + ''
                }
              ''
            );
          in
          [
            (lib.nameValuePair "netns-instance-${name}" {
              inherit (config.lantian.netns."${name}") enable;
              wantedBy = [ "multi-user.target" ];
              after = [ "network-pre.target" ];
              path = [
                pkgs.iproute2
                pkgs.procps
              ];
              script = ''
                set -x
                # Setup namespace
                ip netns add ${name}
                ${ipns} link set lo up
                # Disable auto generated IPv6 link local address
                ${sysctl} -w net.ipv6.conf.default.autoconf=0
                ${sysctl} -w net.ipv6.conf.all.autoconf=0
                ${sysctl} -w net.ipv6.conf.default.accept_ra=0
                ${sysctl} -w net.ipv6.conf.all.accept_ra=0
                ${sysctl} -w net.ipv6.conf.default.addr_gen_mode=1 || true
                ${sysctl} -w net.ipv6.conf.all.addr_gen_mode=1 || true
                # Setup veth pair
                ip link add ns-${interface} type veth peer eth0 netns ${name}
                # https://serverfault.com/questions/935366/why-does-arp-ignore-1-break-arp-on-pointopoint-interfaces-kvm-guest
                sysctl -w net.ipv4.conf.ns-${interface}.arp_ignore=0
                sysctl -w net.ipv4.conf.ns-${interface}.arp_announce=0
                ${sysctl} -w net.ipv4.conf.eth0.arp_ignore=0
                ${sysctl} -w net.ipv4.conf.eth0.arp_announce=0
                ${overrideRoutingTableCommands "add"}
                # Host side network config
                ip link set ns-${interface} up
                ip addr add ${ltnet.IPv4} peer ${value.ipv4} dev ns-${interface}
                ip -6 addr add ${ltnet.IPv6} dev ns-${interface}
                ip -6 addr add fe80::1/64 dev ns-${interface}
                ip -6 route add ${value.ipv6} via fe80::${value.ipSuffix} dev ns-${interface}
                # Namespace side network config
                ${ipns} link set eth0 up
                ${ipns} addr add ${value.ipv4} peer ${ltnet.IPv4} dev eth0
                ${ipns} -6 addr add ${value.ipv6} dev eth0
                ${ipns} -6 addr add fe80::${value.ipSuffix}/64 dev eth0
                ${ipns} route add default via ${ltnet.IPv4} dev eth0
                ${ipns} -6 route add default via fe80::1 dev eth0
              ''
              + (lib.optionalString value.enableBird ''
                # Announced addresses
                ${ipns} link add dummy0 type dummy
                ${ipns} link set dummy0 up
                ${lib.concatMapStringsSep "\n" (ip: "${ipns} addr add ${ip} dev dummy0") value.announcedIPv4}
                ${lib.concatMapStringsSep "\n" (ip: "${ipns} addr add ${ip} dev dummy0") value.announcedIPv6}
              '');

              preStart = ''
                # Ignore failures
                set +e

                ip netns delete ${name}

                exit 0
              '';

              postStop = ''
                # Ignore failures
                set +e

                ip link del ns-${interface}
                ${ipns} link del dummy0
                ip netns delete ${name}
                ${overrideRoutingTableCommands "del"}

                exit 0
              '';

              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
            })
            (lib.nameValuePair "netns-bird-${name}" (
              value.bind {
                enable = value.enable && value.enableBird;
                description = "BIRD (in netns ${name})";
                wantedBy = [ "multi-user.target" ];
                bindsTo = value.birdBindTo;
                serviceConfig = LT.networkToolHarden // {
                  Restart = "on-failure";
                  ExecStart = "${pkgs.bird2}/bin/bird -f -c ${birdConfig} -s /run/bird-${name}/bird-${name}.ctl";
                  CPUQuota = "10%";

                  User = "bird";
                  Group = "bird";
                  RuntimeDirectory = "bird-${name}";
                };
              }
            ))
          ]
        ) config.lantian.netns
      )
    );
  };
}
