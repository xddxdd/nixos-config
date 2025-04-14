{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "skip-silence";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };
}
