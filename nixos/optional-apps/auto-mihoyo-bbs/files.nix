{ stdenvNoCC
, sources
, ...
}:

stdenvNoCC.mkDerivation {
  inherit (sources.auto-mihoyo-bbs) pname version src;

  patches = [ ./auto-mihoyo-bbs-appkey-from-env.patch ];

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/
  '';
}
