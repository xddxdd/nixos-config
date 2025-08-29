{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "libltnginx";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };
}
