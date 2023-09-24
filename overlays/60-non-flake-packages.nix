{inputs, ...}: final: prev: let
  sources = final.callPackage ../helpers/_sources/generated.nix {};
in {
  composer2nix = final.callPackage (inputs.composer2nix) {};

  web-compressor = final.rustPlatform.buildRustPackage {
    inherit (sources.web-compressor) pname version src;

    nativeBuildInputs = with final; [cmake];
    buildInputs = with final; [zlib-ng];

    cargoSha256 = "sha256-9dU/fhTuGG5XX9rJdMS+7K56aA+tHoHowITttn7uLB8=";
  };
}
