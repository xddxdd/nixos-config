{ lib, rustPlatform }:
let
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
      ../smfc/src
    ];
  };
in
rustPlatform.buildRustPackage {
  pname = "asrock-fan-control";
  version = "0.1.0";
  inherit src;
  sourceRoot = "${src.name}/asrock-fan-control";
  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Fail-safe ASRock IPMI and Tesla P40 fan controller";
    mainProgram = "asrock-fan-control";
    platforms = lib.platforms.linux;
  };
}
