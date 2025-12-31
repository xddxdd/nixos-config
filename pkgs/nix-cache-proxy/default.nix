{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "nix-cache-proxy";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };
}
