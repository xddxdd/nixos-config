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

  env.RUSTC_BOOTSTRAP = 1;
  env.RUSTFLAGS = "-Zlocation-detail=none -Zfmt-debug=none";

  buildInputs = [ c-ares ];
  nativeBuildInputs = [
    autoconf
    pkg-config
  ];

  meta.mainProgram = "e164-verify";
}
