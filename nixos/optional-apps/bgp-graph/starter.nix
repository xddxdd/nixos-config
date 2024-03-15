{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  forEachNode =
    instance: instanceCfg: node:
    let
      sanitizeName =
        n: builtins.replaceStrings [ "_" ] [ "-" ] (lib.toLower (LT.sanitizeName "${instance}-${n}"));
    in
    [
      "bgp-graph-netns-${sanitizeName node.name}.service"
      "bgp-graph-bird-${sanitizeName node.name}.service"
    ];

  forEachEdge = instance: instanceCfg: edge: [
    "bgp-graph-edge-${instance}-${builtins.toString edge.fromId}-${builtins.toString edge.toId}.service"
  ];

  bgpGraphServices = lib.flatten (
    lib.mapAttrsToList (
      instance: cfg:
      (builtins.map (forEachNode instance cfg) cfg.nodes)
      ++ (builtins.map (forEachEdge instance cfg) cfg.edges)
    ) config.lantian.bgp-graph
  );
in
{
  systemd.services.bgp-graph = {
    wantedBy = [
      "multi-user.target"
      "network.target"
    ];
    after = [ "network-pre.target" ] ++ bgpGraphServices;
    requires = bgpGraphServices;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };
}
