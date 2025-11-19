{
  pkgs ? { },
  lib ? pkgs.lib,
  ...
}:
let
  call =
    path:
    lib.callPackageWith (
      pkgs
      // {
        inherit lib;
      }
      // result
    ) path { };

  asteriskMusics = call ./constants/asterisk-musics.nix;
  bindfsOptions = call ./constants/bindfs-options.nix;
  networks = call ./constants/networks.nix;
  ports = call ./constants/ports.nix;
  matrixWellKnown = call ./constants/matrix-well-known.nix;
  nix = call ./constants/nix.nix;
  misc = call ./constants/misc.nix;
  interfacePrefixesAttrs = call ./constants/interface-prefixes.nix;
  zonesAttrs = call ./constants/zones.nix;
  publicSites = call ./constants/public-sites.nix;

  result = {
    inherit asteriskMusics;
    inherit (bindfsOptions) bindfsMountOptions bindfsMountOptions';
    inherit (networks) dn42 neonetwork reserved;
    inherit matrixWellKnown;
    inherit nix;
    inherit (ports) port portStr;
    inherit (misc)
      forceX11WrapperArgs
      stateVersion
      soundfontPath
      tags
      ;
    inherit (interfacePrefixesAttrs) interfacePrefixes;
    inherit (zonesAttrs) zones;
    inherit publicSites;
  };
in
result
