{
  lib,
  stdenv,
  fetchurl,
  unar,
  callPackage,
  ...
} @ args:
stdenv.mkDerivation rec {
  pname = "mota-xinxin";
  version = "20210930";

  src = fetchurl {
    url = "https://h5mota.com/games/xinxin/xinxin.zip";
    sha256 = "173g099pxqm4qr0lwp8i6n0fdkjjl7qajwnynsrnfy6klggkkvrv";
  };

  nativeBuildInputs = [unar];

  unpackPhase = ''
    unar -e gb18030 $src
  '';

  installPhase = ''
    mkdir -p $out
    cp -r xinxinban/* $out/
    rm -rf \
      $out/_* \
      $out/*.exe \
      $out/*.py \
      $out/*.url \
      $out/editor* \
      $out/常用工具
  '';
}
