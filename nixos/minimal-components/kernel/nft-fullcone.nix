{
  stdenv,
  lib,
  callPackage,
  kernel,
  kmod,
  ...
}: let
  sources = callPackage ../../../helpers/_sources/generated.nix {};
in
  stdenv.mkDerivation rec {
    inherit (sources.nft-fullcone) pname version src;
    sourceRoot = "source/src";

    patches = [
      ../../../patches/nft-fullcone.patch
    ];

    hardeningDisable = ["pic" "format"];
    nativeBuildInputs = kernel.moduleBuildDependencies;

    KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
    INSTALL_MOD_PATH = placeholder "out";

    inherit (kernel) makeFlags;
    preBuild = ''
      makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
    '';
    installTargets = ["modules_install"];
  }
