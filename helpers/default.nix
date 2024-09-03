{
  config ? { },
  pkgs ? { },
  lib ? pkgs.lib,
  inputs,
  nixosConfigurations ? null,
  self ? null,
  hostsBase ? ../hosts,
  ...
}:
let
  mkScope =
    f:
    let
      # Modified from lib.callPackageWith
      call =
        file:
        let
          f = import file;
          callFn =
            f:
            let
              fargs = lib.functionArgs f;
              allArgs = builtins.intersectAttrs fargs (pkgs // scope);
              missingArgs = lib.attrNames (
                lib.filterAttrs (_name: value: !value) (removeAttrs fargs (lib.attrNames allArgs))
              );
            in
            if missingArgs == [ ] then f allArgs else null;
        in
        if lib.isFunction f then callFn f else f;
      scope = f call;
    in
    scope;
in
mkScope (call: rec {
  inherit
    config
    pkgs
    lib
    inputs
    nixosConfigurations
    hostsBase
    ;
  inherit (inputs.nix-math.lib) math;

  constants = call ./constants.nix;
  inherit (constants) port portStr tags;
  geo = call ./geo.nix;

  sources = call _sources/generated.nix;

  hosts = call ./fn/hosts.nix;
  this = hosts."${config.networking.hostName}";
  otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

  hostsWithTag = tag: lib.filterAttrs (_n: v: v.hasTag tag) hosts;
  hostsWithoutTag = tag: lib.filterAttrs (_n: v: !(v.hasTag tag)) hosts;

  patchedNixpkgs = self.packages."${this.system}".nixpkgs-patched;

  container = call ./fn/container.nix;
  enumerateList = call ./fn/enumerate-list.nix;
  gui = call ./fn/gui.nix;
  ls = call ./fn/ls.nix;
  nginx = call ./fn/nginx.nix;
  sanitizeName = call ./fn/sanitize-name.nix;
  serviceHarden = call ./fn/service-harden.nix;
  tagsForHost = call ./fn/tags-for-host.nix;
  translit = call ./fn/translit.nix;
  uuid = call ./fn/uuid.nix;
  wrapNetns = call ./fn/wrap-netns.nix;
})
