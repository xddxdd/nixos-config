{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  birdForNode = instance: instanceCfg: node: let
    sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));
  in {
    name = "bgp-graph-bird-${sanitizeName node.name}";
    value = let
      netnsName = "bgp-graph-${sanitizeName node.name}";
      routerId = LT.net.ip.add node.id "0.0.0.0";
      neighbors = builtins.filter (v: v != null) (builtins.map (v:
        if v.fromId == node.id
        then v // {neighborId = v.toId;}
        else if v.toId == node.id
        then v // {neighborId = v.fromId;}
        else null)
      instanceCfg.edges);

      ip = LT.net.cidr.host node.id instanceCfg.baseCidr;
      asn = instanceCfg.baseAsn + node.id;
      linkLocalIp = LT.net.cidr.host node.id "fe80::/10";

      neighborName = n: instanceCfg.nodeIdMap."${builtins.toString n.neighborId}".name;
      neighborAsn = n: instanceCfg.baseAsn + n.neighborId;
      neighborLinkLocalIp = n: LT.net.cidr.host n.neighborId "fe80::/10";

      birdConfig = pkgs.writeText "bgp-graph-bird-${sanitizeName node.name}.conf" (builtins.concatStringsSep "" ([
          ''
            log stderr { error, fatal };

            router id ${routerId};
            protocol device {
              scan time 10;
            }

            protocol static {
              ipv6;
              route ${ip}/128 unreachable { bgp_med = 0; };
            }

            protocol kernel {
              scan time 20;
              ipv6 {
                import none;
                export all;
              };
            };

            template bgp bgpgraph {
              local ${linkLocalIp} as ${builtins.toString asn};
              enable extended messages on;
              enforce first as on;
              path metric yes;
              med metric yes;
              graceful restart yes;

              ipv6 {
                next hop self yes;
                extended next hop yes;
              };
            };
          ''
        ]
        ++ builtins.map (n: ''
          protocol bgp bgp_graph_${lib.toLower (LT.sanitizeName (neighborName n))} from bgpgraph {
            neighbor ${neighborLinkLocalIp n} as ${builtins.toString (neighborAsn n)};
            interface "v${builtins.toString n.neighborId}";
            direct;
            ipv6 {
              import all;
              export filter {
                bgp_med = bgp_med + ${builtins.toString n.distance};
                accept;
              };
            };
          }
        '')
        neighbors));
    in {
      wantedBy = ["multi-user.target" "network.target"];
      after = ["network-pre.target" "bgp-graph-netns-${sanitizeName node.name}.service"];
      requires = ["bgp-graph-netns-${sanitizeName node.name}.service"];
      bindsTo = ["bgp-graph-netns-${sanitizeName node.name}.service"];
      serviceConfig = {
        # Type = "forking";
        Restart = "on-failure";
        ExecStart = "${pkgs.bird}/bin/bird -f -c ${birdConfig} -s /run/bird.${netnsName}.ctl -u bird2 -g bird2";
        # ExecStop = "${pkgs.bird}/bin/birdc -s /run/bird.${netnsName}.ctl down";
        CPUQuota = "10%";
        NetworkNamespacePath = "/run/netns/${netnsName}";

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
in {
  systemd.services = builtins.listToAttrs (lib.flatten (lib.mapAttrsToList (
      instance: cfg:
        builtins.map (birdForNode instance cfg) cfg.nodes
    )
    config.lantian.bgp-graph));
}
