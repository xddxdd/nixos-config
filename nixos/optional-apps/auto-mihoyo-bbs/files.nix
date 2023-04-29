{
  stdenvNoCC,
  fetchurl,
  zstd,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "auto-mihoyo-bbs";
  version = "1.0.0";
  src = fetchurl {
    url = "https://private.xuyh0120.win/auto-mihoyo-bbs.tar.zst";
    sha256 = "0hgwf1fici8jnqs94f9q7alhszadqqm3ns7s1kqxd0g7fm4f27mf";
  };

  nativeBuildInputs = [zstd];

  installPhase = ''
    mkdir -p $out/
    cp -r * $out/
  '';
}
