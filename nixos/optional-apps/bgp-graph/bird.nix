{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  birdConfigs = let
    create-base = pkgs.writeShellScriptBin "create-base" ''
      ROUTER_ID=$1
      IP=$2
      LINK_LOCAL_IP=$3
      ASN=$4
      OUTPUT=$5

      cat > $OUTPUT <<EOF
      log stderr { error, fatal };

      router id $ROUTER_ID;
      protocol device {
        scan time 10;
      }

      protocol static {
        ipv6;
        route $IP/128 unreachable { bgp_med = 0; };
      }

      protocol kernel {
        scan time 20;
        ipv6 {
          import none;
          export all;
        };
      };

      template bgp bgpgraph {
        local $LINK_LOCAL_IP as $ASN;
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
      EOF
    '';
    create-peer = pkgs.writeShellScriptBin "create-peer" ''
      PROTOCOL_NAME=$1
      NEIGHBOR_ID=$2
      LINK_LOCAL_IP=$3
      ASN=$4
      DISTANCE=$5
      OUTPUT=$6

      cat >> $OUTPUT <<EOF
      protocol bgp bgp_graph_$PROTOCOL_NAME from bgpgraph {
        neighbor $LINK_LOCAL_IP as $ASN;
        interface "v$NEIGHBOR_ID";
        direct;
        ipv6 {
          import all;
          export filter {
            bgp_med = bgp_med + $DISTANCE;
            accept;
          };
        };
      }
      EOF
    '';

    forEachNode = instance: instanceCfg: node: let
      sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));

      routerId = LT.net.ip.add node.id "0.0.0.0";
      ip = LT.net.cidr.host node.id instanceCfg.baseCidr;
      asn = instanceCfg.baseAsn + node.id;
      linkLocalIp = LT.net.cidr.host node.id "fe80::/10";
      filename = "${sanitizeName node.name}.conf";
    in ''
      create-base ${routerId} ${ip} ${linkLocalIp} ${builtins.toString asn} $out/${filename}
    '';

    forEachEdge = instance: instanceCfg: edge: let
      sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));

      fromName = instanceCfg.nodeIdMap."${builtins.toString edge.fromId}".name;
      fromAsn = instanceCfg.baseAsn + edge.fromId;
      fromLinkLocalIp = LT.net.cidr.host edge.fromId "fe80::/10";
      fromFilename = "${sanitizeName fromName}.conf";

      toName = instanceCfg.nodeIdMap."${builtins.toString edge.toId}".name;
      toAsn = instanceCfg.baseAsn + edge.toId;
      toLinkLocalIp = LT.net.cidr.host edge.toId "fe80::/10";
      toFilename = "${sanitizeName toName}.conf";
    in ''
      create-peer ${lib.toLower (LT.sanitizeName toName)} ${builtins.toString edge.toId} ${toLinkLocalIp} ${builtins.toString toAsn} ${builtins.toString edge.distance} $out/${fromFilename}
      create-peer ${lib.toLower (LT.sanitizeName fromName)} ${builtins.toString edge.fromId} ${fromLinkLocalIp} ${builtins.toString fromAsn} ${builtins.toString edge.distance} $out/${toFilename}
    '';
  in
    pkgs.runCommand "bgp-graph-bird" {
      nativeBuildInputs = [create-base create-peer];
    } (lib.concatStringsSep "\n" (lib.flatten ([
        ''
          mkdir -p $out
        ''
      ]
      ++ lib.mapAttrsToList (
        instance: cfg:
          (builtins.map (forEachNode instance cfg) cfg.nodes)
          ++ (builtins.map (forEachEdge instance cfg) cfg.edges)
      )
      config.lantian.bgp-graph)));

  birdForNode = instance: instanceCfg: node: let
    sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));
  in {
    name = "bgp-graph-bird-${sanitizeName node.name}";
    value = let
      netnsName = "bgp-graph-${sanitizeName node.name}";
      filename = "${sanitizeName node.name}.conf";
      birdConfig = "${birdConfigs}/${filename}";
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
