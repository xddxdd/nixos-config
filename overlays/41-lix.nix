_: final: prev: rec {
  inherit (prev.lixPackageSets.latest)
    nix-eval-jobs
    ;

  nixpkgs-review = prev.nixpkgs-review.override {
    nix = prev.lixPackageSets.latest.lix;
  };

  nil = prev.nil.override {
    nix = prev.lixPackageSets.latest.lix;
  };

  nix-direnv = prev.nix-direnv.override {
    nix = prev.lixPackageSets.latest.lix;
  };

  nix-fast-build = prev.nix-fast-build.override {
    inherit nix-eval-jobs;
  };

  nix-update = prev.nix-update.override {
    nix = prev.lixPackageSets.latest.lix;
    inherit nixpkgs-review;
  };

  nix-init = prev.nix-init.override {
    nix = prev.lixPackageSets.latest.lix;
    inherit nurl;
  };

  nurl = prev.nurl.override {
    nix = prev.lixPackageSets.latest.lix;
  };
}
