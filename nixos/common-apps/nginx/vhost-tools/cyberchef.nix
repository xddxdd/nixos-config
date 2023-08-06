{
  lib,
  stdenvNoCC,
  sources,
  unzip,
  ...
} @ args:
stdenvNoCC.mkDerivation rec {
  inherit (sources.cyberchef) pname version src;

  nativeBuildInputs = [unzip];
  sourceRoot = ".";

  buildPhase = ''
    mv CyberChef_${version}.html index.html
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
