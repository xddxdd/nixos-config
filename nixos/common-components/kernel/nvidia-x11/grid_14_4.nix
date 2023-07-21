import lib/grid_base.nix {
  version = "510.108.03";
  sha256_64bit = "0ka3laf7qp2cl1sc93s6plb2qssjqiidpdan0392vgdxk7i5pd3a";
  settingsSha256 = "sha256-7Zb7HLZQySs6+T2E5HT19vI4m74gjb9Q8YkW0c0c1So=";
  settingsVersion = "510.108.03";
  persistencedSha256 = "sha256-P4DrUYLuQ8chQhoijp2Hd+FOVDejymk9gGA/vNi+VRM=";
  persistencedVersion = "510.108.03";
  patches = [
    ./grid_14_4-kernel-6_1.patch
  ];
}
