{
  lib,
  rustPlatform,
  cmake,
  zlib-ng,
}:
rustPlatform.buildRustPackage {
  pname = "web-compressor";
  version = "0.1.0";
  src = ./.;

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ zlib-ng ];

  meta = {
    description = "Pre-compress static web assets with Gzip, Brotli and Zstd";
    license = lib.licenses.unlicense;
    mainProgram = "web-compressor";
  };
}
