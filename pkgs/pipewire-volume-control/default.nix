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

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ libpulseaudio ];

  meta.mainProgram = "pipewire-volume-control";
}
