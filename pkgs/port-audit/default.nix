{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "port-audit";
  version = "0.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta.mainProgram = "port-audit";
}
