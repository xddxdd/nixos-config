{ inputs, ... }:
final: _prev:
let
  sources = final.callPackage ../helpers/_sources/generated.nix { };
in
{
  composer2nix = final.callPackage inputs.composer2nix { };

  dwarffs = inputs.dwarffs.packages."${final.system}".default;

  web-compressor = final.rustPlatform.buildRustPackage {
    inherit (sources.web-compressor) pname version src;
    useFetchCargoVendor = true;

    nativeBuildInputs = with final; [ cmake ];
    buildInputs = with final; [ zlib-ng ];

    cargoHash = "sha256-BmbYzdeBxLk+ToHlKF/1gCyROR1HSWZIRvXwswCnjEs=";
  };
}
