{
  stdenvNoCC,
  sources,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.cyberchef) pname version src;

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  buildPhase = ''
    mv CyberChef_${version}.html index.html
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    rm -f $out/env-vars
  '';
}
