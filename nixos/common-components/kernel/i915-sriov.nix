{ stdenv
, lib
, callPackage
, kernel
, kmod
, ...
}:

let
  sources = callPackage ../../../helpers/_sources/generated.nix { };
in
stdenv.mkDerivation rec {
  pname = "i915-sriov";
  inherit (sources.i915-sriov-dkms) version src;

  patches = [
    ../../../patches/i915-sriov-dkms-xanmod.patch
  ];

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  inherit (kernel) makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];
}
