{
  lib,
  stdenvNoCC,
  callPackage,
  sources,
  nodejs,
  ...
} @ args: let
  package = callPackage (sources.keycloak-lantian.src + "/default.nix") {};
  nodeModules = "${package.package}/lib/node_modules/keycloak-lantian/node_modules";
in
  stdenvNoCC.mkDerivation {
    inherit (sources.keycloak-lantian) pname version src;
    buildInputs = [nodejs];
    buildPhase = ''
      ln -s ${nodeModules} ./node_modules
      node ${nodeModules}/webpack-cli/bin/cli.js
    '';
    installPhase = ''
      mkdir -p $out
      cp -r login $out/
    '';
  }
