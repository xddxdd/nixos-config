{ config ? { }
, pkgs ? { }
, lib ? pkgs.lib
, ...
}:

let
  args = rec {
    constants = import ./constants.nix;
    hosts = builtins.mapAttrs
      (import ./host-defaults.nix { inherit lib roles; })
      (import ./hosts.nix);
    this = builtins.getAttr config.networking.hostName hosts;
    otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

    roles = import ./roles.nix;
    serverHosts = lib.filterAttrs (n: v: v.role == roles.server) hosts;
    nixosHosts = lib.filterAttrs (n: v: v.role != roles.non-nixos) hosts;

    containerIP = import ./container-ip.nix;
    dnssecKeys = import ./dnssec-keys.nix;
    port = import ./port.nix;
    portStr = lib.mapAttrsRecursive (k: builtins.toString) port;

    serviceHarden = import ./service-harden.nix { inherit lib; };
    sources = pkgs.callPackage _sources/generated.nix { };
  };
  callHelper = f: lib.callPackageWith
    (pkgs // args // { inherit config; })
    f
    { };
in
if config == { } && pkgs == { } then args else
args // rec {
  container = callHelper ./container.nix;
  gui = callHelper ./gui.nix;
  netns = callHelper ./netns.nix;
  nginx = callHelper ./nginx.nix;
  uuid = callHelper ./uuid.nix;
  wrapNetns = callHelper ./wrap-netns.nix;
}
