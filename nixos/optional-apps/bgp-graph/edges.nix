{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  edgeServices = let
    ipbin = "${pkgs.iproute2}/bin/ip";
    create-conf = pkgs.writeShellScriptBin "create-conf" ''
      FROM_NETNS=$1
      TO_NETNS=$2
      FROM_ID=$3
      TO_ID=$4
      FROM_LINK_LOCAL=$5
      TO_LINK_LOCAL=$6
      FROM_SERVICE=$7
      TO_SERVICE=$8
      OUTPUT=$9

      cat > $OUTPUT <<EOF
      [Unit]
      After=network-pre.target $FROM_SERVICE $TO_SERVICE
      Requires=$FROM_SERVICE $TO_SERVICE

      [Service]
      # Setup veth pair
      ExecStart=${ipbin} netns exec $FROM_NETNS ${ipbin} link add v$TO_ID type veth peer t$FROM_ID$TO_ID
      ExecStart=${ipbin} netns exec $FROM_NETNS ${ipbin} link set t$FROM_ID$TO_ID netns $TO_NETNS
      ExecStart=${ipbin} netns exec $TO_NETNS ${ipbin} link set t$FROM_ID$TO_ID name v$FROM_ID

      # https://serverfault.com/questions/935366/why-does-arp-ignore-1-break-arp-on-pointopoint-interfaces-kvm-guest
      ExecStart=${ipbin} netns exec $FROM_NETNS ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.v$TO_ID.arp_ignore=0
      ExecStart=${ipbin} netns exec $FROM_NETNS ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.v$TO_ID.arp_announce=0
      ExecStart=${ipbin} netns exec $TO_NETNS ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.v$FROM_ID.arp_ignore=0
      ExecStart=${ipbin} netns exec $TO_NETNS ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.v$FROM_ID.arp_announce=0

      # Setup LL IP
      ExecStart=${ipbin} netns exec $FROM_NETNS ${ipbin} link set v$TO_ID up
      ExecStart=${ipbin} netns exec $FROM_NETNS ${ipbin} addr add $FROM_LINK_LOCAL/10 dev v$TO_ID
      ExecStart=${ipbin} netns exec $TO_NETNS ${ipbin} link set v$FROM_ID up
      ExecStart=${ipbin} netns exec $TO_NETNS ${ipbin} addr add $TO_LINK_LOCAL/10 dev v$FROM_ID

      ExecStartPre=-${ipbin} netns exec $FROM_NETNS ${ipbin} link del v$TO_ID
      ExecStartPre=-${ipbin} netns exec $TO_NETNS ${ipbin} link del v$FROM_ID
      ExecStopPost=${ipbin} netns exec $FROM_NETNS ${ipbin} link del v$TO_ID
      ExecStopPost=${ipbin} netns exec $TO_NETNS ${ipbin} link del v$FROM_ID
      RemainAfterExit=true
      Type=oneshot
      EOF
    '';

    forEachEdge = instance: instanceCfg: edge: let
      sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));

      fromNode = instanceCfg.nodeIdMap."${builtins.toString edge.fromId}";
      toNode = instanceCfg.nodeIdMap."${builtins.toString edge.toId}";

      fromLinkLocal = LT.net.cidr.host fromNode.id "fe80::/10";
      toLinkLocal = LT.net.cidr.host toNode.id "fe80::/10";

      unitName = "bgp-graph-edge-${instance}-${builtins.toString edge.fromId}-${builtins.toString edge.toId}.service";
    in ''
      create-conf \
        bgp-graph-${sanitizeName fromNode.name} \
        bgp-graph-${sanitizeName toNode.name} \
        ${builtins.toString edge.fromId} \
        ${builtins.toString edge.toId} \
        ${fromLinkLocal} \
        ${toLinkLocal} \
        bgp-graph-netns-${sanitizeName fromNode.name}.service \
        bgp-graph-netns-${sanitizeName toNode.name}.service \
        $out/etc/systemd/system/${unitName}
    '';
  in
    pkgs.runCommand "bgp-graph-edges" {
      nativeBuildInputs = [create-conf];
    } (lib.concatStringsSep "\n" (lib.flatten ([
        ''
          mkdir -p $out/etc/systemd/system
        ''
      ]
      ++ lib.mapAttrsToList (
        instance: cfg: (builtins.map (forEachEdge instance cfg) cfg.edges)
      )
      config.lantian.bgp-graph)));
in {
  systemd.packages = [edgeServices];
}
