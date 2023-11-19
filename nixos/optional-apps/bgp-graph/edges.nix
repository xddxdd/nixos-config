{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  svcForEdge = instance: instanceCfg: edge: let
    sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));
  in {
    name = "bgp-graph-edge-${instance}-${builtins.toString edge.fromId}-${builtins.toString edge.toId}";
    value = let
      fromNode = instanceCfg.nodeIdMap."${builtins.toString edge.fromId}";
      toNode = instanceCfg.nodeIdMap."${builtins.toString edge.toId}";

      fromNetns = "bgp-graph-${sanitizeName fromNode.name}";
      toNetns = "bgp-graph-${sanitizeName toNode.name}";

      fromLinkLocal = LT.net.cidr.host fromNode.id "fe80::/10";
      toLinkLocal = LT.net.cidr.host toNode.id "fe80::/10";

      ipbin = "${pkgs.iproute2}/bin/ip";
      fromIpNs = "${ipbin} netns exec ${fromNetns} ${ipbin}";
      toIpNs = "${ipbin} netns exec ${toNetns} ${ipbin}";
      fromSysctl = "${ipbin} netns exec ${fromNetns} ${pkgs.procps}/bin/sysctl";
      toSysctl = "${ipbin} netns exec ${toNetns} ${pkgs.procps}/bin/sysctl";
    in {
      wantedBy = ["multi-user.target" "network.target"];
      after = [
        "network-pre.target"
        "bgp-graph-netns-${sanitizeName fromNode.name}.service"
        "bgp-graph-netns-${sanitizeName toNode.name}.service"
      ];
      requires = [
        "bgp-graph-netns-${sanitizeName fromNode.name}.service"
        "bgp-graph-netns-${sanitizeName toNode.name}.service"
      ];
      script = ''
        set -x

        # Setup veth pair
        FROM_IF=v${builtins.toString toNode.id}
        TO_IF=v${builtins.toString fromNode.id}
        TEMP_IF=t${builtins.toString fromNode.id}${builtins.toString toNode.id}

        ${fromIpNs} link add $FROM_IF type veth peer $TEMP_IF
        ${fromIpNs} link set $TEMP_IF netns ${toNetns}
        ${toIpNs} link set $TEMP_IF name $TO_IF

        # https://serverfault.com/questions/935366/why-does-arp-ignore-1-break-arp-on-pointopoint-interfaces-kvm-guest
        ${fromSysctl} -w net.ipv4.conf.$FROM_IF.arp_ignore=0
        ${fromSysctl} -w net.ipv4.conf.$FROM_IF.arp_announce=0
        ${toSysctl} -w net.ipv4.conf.$TO_IF.arp_ignore=0
        ${toSysctl} -w net.ipv4.conf.$TO_IF.arp_announce=0

        # Setup LL IP
        ${fromIpNs} link set $FROM_IF up
        ${fromIpNs} addr add ${fromLinkLocal}/10 dev $FROM_IF
        ${toIpNs} link set $TO_IF up
        ${toIpNs} addr add ${toLinkLocal}/10 dev $TO_IF
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStartPre = [
          "-${fromIpNs} link del v${builtins.toString toNode.id}"
          "-${toIpNs} link del v${builtins.toString fromNode.id}"
        ];
        ExecStopPost = [
          "${fromIpNs} link del v${builtins.toString toNode.id}"
          "${toIpNs} link del v${builtins.toString fromNode.id}"
        ];
      };
    };
  };
in {
  systemd.services = builtins.listToAttrs (lib.flatten (lib.mapAttrsToList (
      instance: cfg:
        builtins.map (svcForEdge instance cfg) cfg.edges
    )
    config.lantian.bgp-graph));
}
