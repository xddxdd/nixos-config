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
  inherit (sources.ovpn-dco) pname version src;

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [ "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

  prePatch = ''
    # Skip depmod
    substituteInPlace Makefile \
      --replace "INSTALL_MOD_DIR=updates/" "INSTALL_MOD_PATH=${placeholder "out"}/" \
      --replace "DEPMOD := depmod -a" "DEPMOD := true"
  '';
}
