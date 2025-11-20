{ rustPlatform }:
rustPlatform.buildRustPackage {
  pname = "hp-keyboard-backlight";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };
}
