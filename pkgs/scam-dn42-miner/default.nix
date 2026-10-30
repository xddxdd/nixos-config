{
  rustPlatform,
  src,
  version,
}:
rustPlatform.buildRustPackage {
  pname = "scam-dn42-miner";
  inherit version src;
  cargoHash = "sha256-+JuKI7/bEAx6gNCPwbarH9LRAHkq6Ox057CXu235P3Q=";
  meta.mainProgram = "scummybank-miner";
}
