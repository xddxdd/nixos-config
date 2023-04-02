{inputs, ...}: final: prev: let
  pkgs-22-05 = inputs.nixpkgs-22-05.legacyPackages."${final.system}";
  pkgs-22-11 = inputs.nixpkgs-22-11.legacyPackages."${final.system}";
in rec {
  # plausible: crashes on oneprovider with latest erlang runtime
  plausible = prev.plausible.override {beamPackages = pkgs-22-05.beamPackages;};

  inherit (pkgs-22-05) linuxPackages_6_0 mysql57;
}
