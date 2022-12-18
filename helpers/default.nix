{ config ? { }
, pkgs ? { }
, lib ? pkgs.lib
, inputs
, ...
}:

let
  args = rec {
    inherit config pkgs lib inputs;

    constants = import ./constants.nix;
    hosts = builtins.mapAttrs hostDefaults (import ./hosts.nix { inherit roles geo; });
    hostDefaults = import ./host-defaults.nix { inherit lib roles; };
    this = hosts."${config.networking.hostName}" or (hostDefaults config.networking.hostName { });
    otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

    flake = import ./flake.nix { inherit lib; };
    geo = import ./geo.nix { inherit pkgs lib sanitizeName inputs; };
    roles = import ./roles.nix;
    serverHosts = lib.filterAttrs (n: v: v.role == roles.server) hosts;
    nixosHosts = lib.filterAttrs (n: v: v.role != roles.non-nixos) hosts;

    containerIP = import ./container-ip.nix;
    dnssecKeys = import ./dnssec-keys.nix;
    port = import ./port.nix;
    portStr = lib.mapAttrsRecursive (k: builtins.toString) port;

    sanitizeName = callHelper ./sanitize-name.nix;
    serviceHarden = import ./service-harden.nix { inherit lib; };
    sources = pkgs.callPackage _sources/generated.nix { };
  };
  callHelper = f: lib.callPackageWith
    (pkgs // args)
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
