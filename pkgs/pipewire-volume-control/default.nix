{
  rustPlatform,
  libpulseaudio,
  autoPatchelfHook,
}:
rustPlatform.buildRustPackage {
  pname = "pipewire-volume-control";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  env.RUSTC_BOOTSTRAP = 1;
  env.RUSTFLAGS = "-Zlocation-detail=none -Zfmt-debug=none";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libpulseaudio ];

  meta.mainProgram = "pipewire-volume-control";
}
