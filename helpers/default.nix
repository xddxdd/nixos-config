{ config
, pkgs
, lib ? pkgs.lib
, ...
}:

let
  args = rec {
    constants = import ./constants.nix;
    hosts = import ./hosts.nix;
    this = builtins.getAttr config.networking.hostName hosts;
    otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

    roles = import ./roles.nix;
    isRole = { role ? roles.server, ... }: expected: role == expected;
    isThisRole = isRole this;
    serverHosts = lib.filterAttrs (n: v: isRole v roles.server) hosts;
    nixosHosts = lib.filterAttrs (n: v: !(isRole v roles.non-nixos)) hosts;

    containerIP = import ./container-ip.nix;
    dnssecKeys = import ./dnssec-keys.nix;
    port = import ./port.nix;
    portStr = lib.mapAttrsRecursive (k: v: builtins.toString v) port;

    serviceHarden = import ./service-harden.nix { inherit lib; };
    sources = pkgs.callPackage _sources/generated.nix { };
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
  uuid = callHelper ./uuid.nix;
  yggdrasil = callHelper ./yggdrasil;
  zshrc = callHelper ./zshrc.nix;
}
