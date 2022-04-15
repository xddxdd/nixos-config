{ inputs, nixpkgs, ... }:

final: prev: rec {
  linux-xanmod-lantian = prev.linux-xanmod-lantian.override { stdenv = final.ccacheStdenv; };
  tdesktop = prev.tdesktop.override { stdenv = final.ccacheStdenv; };
}
