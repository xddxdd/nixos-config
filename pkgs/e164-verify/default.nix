{
  rustPlatform,
  c-ares,
  autoconf,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  pname = "e164-verify";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  buildInputs = [ c-ares ];
  nativeBuildInputs = [
    autoconf
    pkg-config
  ];

  meta.mainProgram = "e164-verify";
}
