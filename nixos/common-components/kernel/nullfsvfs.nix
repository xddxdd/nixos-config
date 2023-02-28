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
    inherit (sources.nullfsvfs) pname version src;

    hardeningDisable = ["pic" "format"];
    nativeBuildInputs = kernel.moduleBuildDependencies;

    KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
    INSTALL_MOD_PATH = placeholder "out";

    patches = [../../../patches/nullfsvfs-change-reported-free-space.patch];

    inherit (kernel) makeFlags;
    preBuild = ''
      makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
    '';
    installTargets = ["modules_install"];
  }
