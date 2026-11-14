{ lib, rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "smfc";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Fail-safe Supermicro IPMI fan controller";
    mainProgram = "smfc";
    platforms = lib.platforms.linux;
  };
}
