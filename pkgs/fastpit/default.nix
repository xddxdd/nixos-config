{ rustPlatform, capnproto }:
rustPlatform.buildRustPackage {
  pname = "fastpit";
  version = "0.1.0";
  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ capnproto ];

  env.RUSTC_BOOTSTRAP = 1;
  env.RUSTFLAGS = "-Zlocation-detail=none -Zfmt-debug=none";

  postInstall = ''
    mkdir -p $out/share/fastpit
    cp -r assets $out/share/fastpit/assets
  '';

  meta.mainProgram = "fastpit";
  meta.description = "Deterministic, corpus-driven LLM tarpit HTTP server";
}
