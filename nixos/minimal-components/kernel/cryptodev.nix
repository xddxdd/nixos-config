{
  stdenv,
  lib,
  callPackage,
  kernel,
  kmod,
}: let
  sources = callPackage ../../../helpers/_sources/generated.nix {};
in
  stdenv.mkDerivation rec {
    inherit (sources.cryptodev-linux) pname version src;

    nativeBuildInputs = kernel.moduleBuildDependencies;
    hardeningDisable = ["pic"];

    makeFlags =
      kernel.makeFlags
      ++ [
        "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        "INSTALL_MOD_PATH=$(out)"
        "prefix=$(out)"
      ];

    meta = {
      description = "Device that allows access to Linux kernel cryptographic drivers";
      homepage = "http://cryptodev-linux.org/";
      maintainers = with lib.maintainers; [moni];
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  }
