{ lib
, stdenv
, fetchurl
, unar
, callPackage
, ...
} @ args:

let
  helpers = callPackage ../helpers.nix { };
in
stdenv.mkDerivation (helpers.compressStaticAssets rec {
  pname = "mota-51";
  version = "20180324";

  src = fetchurl {
    url = "https://h5mota.com/games/51/51.zip";
    sha256 = "03j9s58q2m2xhzg7173yn1j7hjqfh6xfy2bs76k1qi7l8f9gxrhj";
  };

  nativeBuildInputs = [ unar ];

  unpackPhase = ''
    unar -e gb18030 $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r 51/* $out/
    rm -rf \
      $out/_* \
      $out/*.exe \
      $out/*.py \
      $out/*.url \
      $out/editor* \
      $out/常用工具
  '';
})
