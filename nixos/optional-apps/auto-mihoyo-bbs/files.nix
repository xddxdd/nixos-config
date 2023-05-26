{
  stdenvNoCC,
  sources,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.mihoyo-bbs-tools) pname version src;

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/

    cp ${./captcha.py} $out/captcha.py
  '';
}
