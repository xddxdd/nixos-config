{
  lib,
  stdenvNoCC,
  callPackage,
  sources,
  nodejs,
  ...
}@args:
stdenvNoCC.mkDerivation {
  inherit (sources.keycloak-lantian) pname version src;
  installPhase = ''
    mkdir -p $out
    cp -r login $out/
  '';
}
