{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "skip-silence";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  env.RUSTC_BOOTSTRAP = 1;
  env.RUSTFLAGS = "-Zlocation-detail=none -Zfmt-debug=none";

  meta.mainProgram = "skip-silence";
}
