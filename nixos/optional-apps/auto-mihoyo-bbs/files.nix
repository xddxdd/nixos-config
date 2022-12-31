{ stdenvNoCC
, sources
, ...
}:

let
  rrocrSrc = sources.auto-mihoyo-bbs-rrocr.src;
in
stdenvNoCC.mkDerivation {
  inherit (sources.auto-mihoyo-bbs) pname version src;

  prePatch = ''
    cp ${rrocrSrc}/captcha.py .
  '';

  patches = [ ./auto-mihoyo-bbs-appkey-from-env.patch ];

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/
  '';
}
