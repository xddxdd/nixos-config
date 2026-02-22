{
  rustPlatform,
  sources,
}:
rustPlatform.buildRustPackage {
  inherit (sources.nix-ubw) pname version src;
  cargoHash = "sha256-GUdP2NoumbpaLZg8loSNcB3qdtmO6+LZBNIjZWrFFBo=";
  meta.mainProgram = "nix-ubw";
}
