{ stdenvNoCC, sources, ... }:
stdenvNoCC.mkDerivation {
  inherit (sources.mihoyo-bbs-tools) pname version src;

  patches = [ ../../../patches/mihoyo-bbs-tools-fix-none.patch ];

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/

    cp ${./captcha.py} $out/captcha.py
  '';
}
