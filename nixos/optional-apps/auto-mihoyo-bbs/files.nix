{ stdenvNoCC
, fetchurl
, zstd
, ...
}:

stdenvNoCC.mkDerivation {
  pname = "auto-mihoyo-bbs";
  version = "1.0.0";
  src = fetchurl {
    url = "https://backblaze.lantian.pub/auto-mihoyo-bbs.tar.zst";
    sha256 = "0h06iyrnlrpbym2k4xdn4hbmywg64h00r7nddr7dgxv9xy7csgss";
  };

  nativeBuildInputs = [ zstd ];

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/
  '';
}
