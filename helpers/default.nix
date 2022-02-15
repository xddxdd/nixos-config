{ config
, pkgs
, lib ? pkgs.lib
, ...
}:

let
  args = rec {
    hosts = import ../hosts.nix;
    this = builtins.getAttr config.networking.hostName hosts;
    otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

    containerIP = import ./container-ip.nix;
    dnssecKeys = import ./dnssec-keys.nix;
    port = import ./port.nix;
    portStr = lib.mapAttrsRecursive (k: v: builtins.toString v) port;
    roles = import ./roles.nix;
    serviceHarden = import ./service-harden.nix { inherit lib; };
  };
  callHelper = f: lib.callPackageWith
    (pkgs // args // { inherit config; })
    f
    { };
in
args // rec {
  container = callHelper ./container.nix;
  netns = callHelper ./netns.nix;
  nginx = callHelper ./nginx.nix;
  yggdrasil = callHelper ./yggdrasil;
  zshrc = callHelper ./zshrc.nix;
}
