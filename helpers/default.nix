{
  config ? {},
  pkgs ? {},
  lib ? pkgs.lib,
  inputs,
  nixosConfigurations ? null,
  ...
}: let
  mkScope = f: let
    # Modified from lib.callPackageWith
    call = file: let
      f = import file;
      callFn = f: let
        fargs = lib.functionArgs f;
        allArgs = builtins.intersectAttrs fargs (pkgs // scope);
        missingArgs =
          lib.attrNames
          (lib.filterAttrs (name: value: ! value)
            (removeAttrs fargs (lib.attrNames allArgs)));
      in
        if missingArgs == []
        then f allArgs
        else null;
    in
      if lib.isFunction f
      then callFn f
      else f;
    scope = f call;
  in
    scope;
in
  mkScope (call: rec {
    inherit config pkgs lib inputs nixosConfigurations;

    constants = call ./constants.nix;
    inherit (constants) port portStr tags;

    sources = call _sources/generated.nix;

    hosts = builtins.mapAttrs hostDefaults (call ./hosts.nix);
    hostDefaults = call ./host-defaults.nix;
    this = hosts."${config.networking.hostName}" or (hostDefaults config.networking.hostName {});
    otherHosts = builtins.removeAttrs hosts [config.networking.hostName];

    hostsWithTag = tag: lib.filterAttrs (n: v: builtins.elem tag v.tags) hosts;
    serverHosts = hostsWithTag tags.server;

    container = call ./container.nix;
    geo = call ./geo.nix;
    gui = call ./gui.nix;
    nginx = call ./nginx.nix;
    sanitizeName = call ./sanitize-name.nix;
    serviceHarden = call ./service-harden.nix;
    uuid = call ./uuid.nix;
    wrapNetns = call ./wrap-netns.nix;
  })
