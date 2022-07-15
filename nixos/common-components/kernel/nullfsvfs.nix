{ stdenv
, lib
, fetchFromGitHub
, kernel
, kmod
, ...
}:

stdenv.mkDerivation rec {
  name = "nullfsvfs";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "abbbi";
    repo = "nullfsvfs";
    rev = "${version}";
    sha256 = "sha256-CdDK8701f3QQ1zYDV7D0Y8uhRmBkuWEuNuGDo0q+VXU=";
  };

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  preBuild = ''
    makeFlags="$makeFlags -C ${KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];
}
