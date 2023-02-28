{
  lib,
  stdenv,
  fetchurl,
  unar,
  callPackage,
  ...
} @ args:
stdenv.mkDerivation rec {
  pname = "mota-24";
  version = "20220620";

  src = fetchurl {
    url = "https://h5mota.com/games/24/24.zip";
    sha256 = "0na2xl11z2yag0gjw4asaaizxxg2sghynaq3xzi0c5c4klf6kr47";
  };

  nativeBuildInputs = [unar];

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
}
