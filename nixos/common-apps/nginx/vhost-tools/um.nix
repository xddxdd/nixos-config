{
  stdenvNoCC,
  sources,
  unzip,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.um-react) pname version src;

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
    rm -f $out/env-vars
  '';
}
