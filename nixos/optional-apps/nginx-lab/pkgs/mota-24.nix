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
  pname = "mota-24";
  version = "20220620";

  src = fetchurl {
    url = "https://h5mota.com/games/24/24.zip";
    sha256 = "02w9lr1y4wdpc3ymhp9n8ms39b43994xvqcfcifh0vmqafhd77kr";
  };

  nativeBuildInputs = [ unar ];

  unpackPhase = ''
    unar -e gb18030 $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r 24/* $out/
    rm -rf \
      $out/_* \
      $out/*.exe \
      $out/*.py \
      $out/*.url \
      $out/editor* \
      $out/常用工具
  '';
})
