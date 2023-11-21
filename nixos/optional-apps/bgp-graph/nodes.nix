{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  nodeServices = let
    ipbin = "${pkgs.iproute2}/bin/ip";
    create-conf = pkgs.writeShellScriptBin "create-conf" ''
      NETNS_NAME=$1
      NETNS_IP=$2
      OUTPUT=$3

      cat > $OUTPUT <<EOF
      [Unit]
      After=network-pre.target

      [Service]
      # Setup namespace
      ExecStart=${ipbin} netns add $NETNS_NAME
      ExecStart=${ipbin} netns exec $NETNS_NAME ${ipbin} link set lo up
      # Enable forwarding
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.default.forwarding=1
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.all.forwarding=1
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.forwarding=1
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.forwarding=1
      # Disable auto generated IPv6 link local address
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.autoconf=0
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.autoconf=0
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.accept_ra=0
      ExecStart=${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.accept_ra=0
      ExecStart=${pkgs.bash}/bin/bash -c "${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.addr_gen_mode=1 || true"
      ExecStart=${pkgs.bash}/bin/bash -c "${ipbin} netns exec $NETNS_NAME ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.addr_gen_mode=1 || true"
      # Setup self IP
      ExecStart=${ipbin} netns exec $NETNS_NAME ${ipbin} link add dummy0 type dummy
      ExecStart=${ipbin} netns exec $NETNS_NAME ${ipbin} link set dummy0 up
      ExecStart=${ipbin} netns exec $NETNS_NAME ${ipbin} addr add $NETNS_IP dev dummy0

      ExecStartPre=-${ipbin} netns delete $NETNS_NAME
      ExecStopPost=${ipbin} netns exec $NETNS_NAME ${ipbin} link del dummy0
      ExecStopPost=${ipbin} netns delete $NETNS_NAME

      RemainAfterExit=true
      Type=oneshot
      EOF
    '';

    forEachNode = instance: instanceCfg: node: let
      sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));

      netnsName = "bgp-graph-${sanitizeName node.name}";
      ip = LT.net.cidr.host node.id instanceCfg.baseCidr;
      unitName = "bgp-graph-netns-${sanitizeName node.name}.service";
    in ''
      create-conf \
        ${netnsName} \
        ${ip} \
        $out/etc/systemd/system/${unitName}
    '';
  in
    pkgs.runCommand "bgp-graph-nodes" {
      nativeBuildInputs = [create-conf];
    } (lib.concatStringsSep "\n" (lib.flatten ([
        ''
          mkdir -p $out/etc/systemd/system
        ''
      ]
      ++ lib.mapAttrsToList (
        instance: cfg: (builtins.map (forEachNode instance cfg) cfg.nodes)
      )
      config.lantian.bgp-graph)));
in {
  systemd.packages = [nodeServices];
}
