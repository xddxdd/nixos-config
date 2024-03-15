{ inputs, ... }:
final: prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
{
  composer2nix = final.callPackage (inputs.composer2nix) { };

  web-compressor = final.rustPlatform.buildRustPackage {
    inherit (sources.web-compressor) pname version src;

    nativeBuildInputs = with final; [ cmake ];
    buildInputs = with final; [ zlib-ng ];

    cargoSha256 = "sha256-gg6BuPDleZLfleB/k2fANgrrJt8cbbXw7sOcw0LoNmk=";
  };
}
