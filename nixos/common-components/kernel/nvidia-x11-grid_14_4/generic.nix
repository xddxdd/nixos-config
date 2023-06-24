{
  lib,
  callPackage,
  pkgs,
  pkgsi686Linux,
  kernel,
  perl,
  nukeReferences,
  which,
  # Options
  useGLVND ? true,
  useProfiles ? true,
  ...
}:
with lib; let
  version = "510.108.03";
  sha256_64bit = "0ka3laf7qp2cl1sc93s6plb2qssjqiidpdan0392vgdxk7i5pd3a";
  settingsSha256 = "sha256-7Zb7HLZQySs6+T2E5HT19vI4m74gjb9Q8YkW0c0c1So=";
  settingsVersion = "510.108.03";
  persistencedSha256 = "sha256-P4DrUYLuQ8chQhoijp2Hd+FOVDejymk9gGA/vNi+VRM=";
  persistencedVersion = "510.108.03";

  nameSuffix = "-${kernel.version}";
  i686bundled = true;

  libPathFor = pkgs:
    lib.makeLibraryPath (with pkgs; [
      gcc-unwrapped
      libdrm
      libGL
      mesa
      stdenv.cc.cc
      wayland
      xorg.libX11
      xorg.libxcb
      xorg.libXext
      xorg.libXrandr
      xorg.libXv
      zlib
    ]);

  self = kernel.stdenv.mkDerivation {
    name = "nvidia-x11-${version}${nameSuffix}";

    builder = ./builder.sh;

    src = pkgs.requireFile rec {
      name = "NVIDIA-Linux-x86_64-${version}-grid.run";
      sha256 = sha256_64bit;
      url = "https://www.nvidia.com/object/vGPU-software-driver.html";
      message = ''
        Unfortunately, we cannot download file ${name} automatically.
        This file can be extracted from vGPU driver's zip file.
        Please go to ${url} to download it yourself, and add it to the Nix store
        using either
          nix-store --add-fixed sha256 ${name}
        or
          nix-prefetch-url --type sha256 file:///path/to/${name}
      '';
    };

    patches = [
      ./kernel-6_1.patch
    ];

    inherit version useGLVND useProfiles;
    inherit (stdenv.hostPlatform) system;
    inherit i686bundled;

    outputs =
      ["out" "bin"]
      ++ optional i686bundled "lib32";
    outputDev = "bin";

    kernel = kernel.dev;
    kernelVersion = kernel.modDirVersion;

    makeFlags =
      kernel.makeFlags
      ++ [
        "IGNORE_PREEMPT_RT_PRESENCE=1"
        "NV_BUILD_SUPPORTS_HMM=1"
        "SYSSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
        "SYSOUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      ];

    hardeningDisable = ["pic" "format"];

    dontStrip = true;
    dontPatchELF = true;

    libPath = libPathFor pkgs;
    libPath32 = optionalString i686bundled (libPathFor pkgsi686Linux);

    buildInputs = [which];
    nativeBuildInputs =
      [perl nukeReferences]
      ++ kernel.moduleBuildDependencies;

    disallowedReferences = [kernel.dev];

    passthru =
      {
        settings = callPackage (import ./settings.nix settingsSha256) {nvidia_x11 = self;};
        persistenced = callPackage (import ./persistenced.nix persistencedSha256) {nvidia_x11 = self;};
        inherit persistencedVersion settingsVersion;
        compressFirmware = false;
      }
      // optionalAttrs (!i686bundled) {
        inherit lib32;
      };

    meta = with lib; {
      homepage = "https://www.nvidia.com/object/unix.html";
      description = "X.org driver and kernel module for NVIDIA graphics cards";
      license = licenses.unfreeRedistributable;
      platforms = ["x86_64-linux"];
      maintainers = with maintainers; [jonringer];
      priority = 4; # resolves collision with xorg-server's "lib/xorg/modules/extensions/libglx.so"
    };
  };
in
  self
