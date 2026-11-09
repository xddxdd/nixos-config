{ stdenvNoCC, sources, ... }:
stdenvNoCC.mkDerivation {
  inherit (sources.ip-please) pname version src;

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out index.html *.js LICENSE OFL-fusion-pixel.txt
    runHook postInstall
  '';
}
