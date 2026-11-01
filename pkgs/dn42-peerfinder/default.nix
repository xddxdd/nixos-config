{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "dn42-peerfinder";
  version = "1.2.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta.mainProgram = "dn42-peerfinder";
}
