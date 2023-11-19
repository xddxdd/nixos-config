{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  svcForNode = instance: instanceCfg: node: let
    sanitizeName = n: builtins.replaceStrings ["_"] ["-"] (lib.toLower (LT.sanitizeName "${instance}-${n}"));
  in {
    name = "bgp-graph-netns-${sanitizeName node.name}";
    value = let
      netnsName = "bgp-graph-${sanitizeName node.name}";
      ip = LT.net.cidr.host node.id instanceCfg.baseCidr;

      ipbin = "${pkgs.iproute2}/bin/ip";
      ipns = "${ipbin} netns exec ${netnsName} ${ipbin}";
      sysctl = "${ipbin} netns exec ${netnsName} ${pkgs.procps}/bin/sysctl";
    in {
      wantedBy = ["multi-user.target" "network.target"];
      after = ["network-pre.target"];
      script = ''
        set -x

        # Setup namespace
        ${ipbin} netns add ${netnsName}
        ${ipns} link set lo up
        # Enable forwarding
        ${sysctl} -w net.ipv4.conf.default.forwarding=1
        ${sysctl} -w net.ipv4.conf.all.forwarding=1
        ${sysctl} -w net.ipv6.conf.default.forwarding=1
        ${sysctl} -w net.ipv6.conf.all.forwarding=1
        # Disable auto generated IPv6 link local address
        ${sysctl} -w net.ipv6.conf.default.autoconf=0
        ${sysctl} -w net.ipv6.conf.all.autoconf=0
        ${sysctl} -w net.ipv6.conf.default.accept_ra=0
        ${sysctl} -w net.ipv6.conf.all.accept_ra=0
        ${sysctl} -w net.ipv6.conf.default.addr_gen_mode=1 || true
        ${sysctl} -w net.ipv6.conf.all.addr_gen_mode=1 || true
        # Setup self IP
        ${ipns} link add dummy0 type dummy
        ${ipns} link set dummy0 up
        ${ipns} addr add ${ip} dev dummy0
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStartPre = [
          "-${ipbin} netns delete ${netnsName}"
        ];
        ExecStopPost = [
          "${ipns} link del dummy0"
          "${ipbin} netns delete ${netnsName}"
        ];
      };
    };
  };
in {
  systemd.services = builtins.listToAttrs (lib.flatten (lib.mapAttrsToList (
      instance: cfg:
        builtins.map (svcForNode instance cfg) cfg.nodes
    )
    config.lantian.bgp-graph));
}
