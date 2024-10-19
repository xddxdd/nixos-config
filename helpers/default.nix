{
  config ? { },
  pkgs ? { },
  lib ? pkgs.lib,
  inputs,
  self ? null,
  hostsBase ? ../hosts,
  ...
}:
let
  call =
    path:
    builtins.removeAttrs (lib.callPackageWith (pkgs // helpers) path { }) [
      "override"
      "overrideDerivation"
    ];
  helpers = rec {
    inherit
      config
      pkgs
      lib
      inputs
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

    patchedNixpkgs = self.packages."${this.system}".pkgs-patched;

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
  };
in
helpers
