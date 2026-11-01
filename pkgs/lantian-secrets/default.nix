{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "lantian-secrets";
  version = "0.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  meta.mainProgram = "lantian-secrets";
}
