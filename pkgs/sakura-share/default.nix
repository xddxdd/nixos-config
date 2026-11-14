{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "sakura-share";
  version = "0.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta.mainProgram = "sakura-share";
}
