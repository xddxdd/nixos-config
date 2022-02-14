{ config, pkgs, hosts, this, containerIP, serviceHarden, ... }:

# Inspired by https://cloudnull.io/2019/04/running-services-in-network-name-spaces-with-systemd/

{ name
, enable ? true
, announcedIPv4 ? [ ]
, announcedIPv6 ? [ ]
, birdBindTo ? [ ]
}:
let
  thisIP = containerIP."${name}";
  interface = builtins.substring 0 12 name;

  ipbin = "${pkgs.iproute2}/bin/ip";
  ipns = "${ipbin} netns exec ns-${name} ${ipbin}";
  sysctl = "${ipbin} netns exec ns-${name} ${pkgs.procps}/bin/sysctl";
in
rec {
  setup = {
    "netns-instance-${name}" = {
      inherit enable;
      wantedBy = [ "multi-user.target" "network-online.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStartPre = [
          "-${ipbin} netns delete ns-${name}"
        ];
        ExecStart = [
          # Setup namespace
          "${ipbin} netns add ns-${name}"
          "${ipns} link set lo up"
          # Disable auto generated IPv6 link local address
          "${sysctl} -w net.ipv6.conf.default.autoconf=0"
          "${sysctl} -w net.ipv6.conf.all.autoconf=0"
          "${sysctl} -w net.ipv6.conf.default.accept_ra=0"
          "${sysctl} -w net.ipv6.conf.all.accept_ra=0"
          "${sysctl} -w net.ipv6.conf.default.addr_gen_mode=1"
          "${sysctl} -w net.ipv6.conf.all.addr_gen_mode=1"
          # Setup veth pair
          "${ipbin} link add ns-${interface} type veth peer ni-${interface}"
          "${ipbin} link set ni-${interface} netns ns-${name}"
          "${ipns} link set ni-${interface} name eth-ns"
          # Host side network config
          "${ipbin} link set ns-${interface} up"
          "${ipbin} addr add ${this.ltnet.IPv4} peer ${this.ltnet.IPv4Prefix}.${thisIP} dev ns-${interface}"
          "${ipbin} -6 addr add ${this.ltnet.IPv6} dev ns-${interface}"
          "${ipbin} -6 addr add fe80::1/64 dev ns-${interface}"
          "${ipbin} -6 route add ${this.ltnet.IPv6Prefix}::${thisIP} via fe80::${thisIP} dev ns-${interface}"
          # Namespace side network config
          "${ipns} link set eth-ns up"
          "${ipns} addr add ${this.ltnet.IPv4Prefix}.${thisIP} peer ${this.ltnet.IPv4} dev eth-ns"
          "${ipns} route add default via ${this.ltnet.IPv4} dev eth-ns"
          "${ipns} -6 addr add ${this.ltnet.IPv6Prefix}::${thisIP} dev eth-ns"
          "${ipns} -6 addr add fe80::${thisIP}/64 dev eth-ns"
          "${ipns} -6 route add default via fe80::1 dev eth-ns"
          # Announced addresses
          "${ipns} link add dummy0 type dummy"
          "${ipns} link set dummy0 up"
        ]
        ++ (builtins.map (ip: "${ipns} addr add ${ip} dev dummy0") announcedIPv4)
        ++ (builtins.map (ip: "${ipns} addr add ${ip} dev dummy0") announcedIPv6);

        ExecStopPost = [
          "${ipbin} link del ns-${interface}"
          "${ipns} link del dummy0"
          "${ipbin} netns delete ns-${name}"
        ];
      };
    };

    "netns-bird-${name}" = bind {
      enable = enable && birdEnabled;
      description = "BIRD (in netns ${name})";
      wantedBy = [ "multi-user.target" ];
      bindsTo = birdBindTo;
      serviceConfig = {
        Type = "forking";
        Restart = "on-failure";
        ExecStart = "${pkgs.bird2}/bin/bird -c ${birdConfig} -s /run/bird.${name}.ctl -u bird2 -g bird2";
        ExecStop = "${pkgs.bird2}/bin/birdc -s /run/bird.${name}.ctl down";

        # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/bird.nix
        CapabilityBoundingSet = [
          "CAP_CHOWN"
          "CAP_FOWNER"
          "CAP_DAC_OVERRIDE"
          "CAP_SETUID"
          "CAP_SETGID"
          # see bird/sysdep/linux/syspriv.h
          "CAP_NET_BIND_SERVICE"
          "CAP_NET_BROADCAST"
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
        ];
        ProtectSystem = "full";
        ProtectHome = "yes";
        SystemCallFilter = "~@cpu-emulation @debug @keyring @module @mount @obsolete @raw-io";
        MemoryDenyWriteExecute = "yes";
      };
    };
  };

  bind = attr:
    if enable then
      ({
        after = (attr.after or [ ]) ++ [ "netns-instance-${name}.service" ];
        bindsTo = (attr.bindsTo or [ ]) ++ [ "netns-instance-${name}.service" ];
        serviceConfig = attr.serviceConfig // {
          NetworkNamespacePath = "/run/netns/ns-${name}";
        };
      } // (builtins.removeAttrs attr [ "after" "bindsTo" "serviceConfig" ])) else attr;

  birdEnabled = (builtins.length (announcedIPv4 ++ announcedIPv6)) > 0;
  birdConfig = pkgs.writeText "bird-netns-${name}.conf" (''
    log stderr { error, fatal };
    router id ${this.ltnet.IPv4Prefix}.${thisIP};
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
  '' + (pkgs.lib.concatStrings (builtins.map
    (ip: ''
      route ${ip}/32 unreachable;
    '')
    announcedIPv4)) + ''
    }

    protocol static {
      ipv6;
  '' + (pkgs.lib.concatStrings (builtins.map
    (ip: ''
      route ${ip}/128 unreachable;
    '')
    announcedIPv6)) + ''
    }
  '');
}
