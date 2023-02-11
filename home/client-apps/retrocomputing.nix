{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  winntMips = pkgs.stdenvNoCC.mkDerivation {
    pname = "winnt-mips";
    version = "1.0";

    nativeBuildInputs = with pkgs; [ unzip ];

    src = pkgs.fetchurl {
      url = "https://web.archive.org/web/20150809205748if_/http://hpoussineau.free.fr/qemu/firmware/magnum-4000/setup.zip";
      sha256 = "0plwj3pg47jigi4bbps5mfgb0phbksqya05azmbv2dcgyfsyxx1l";
    };

    unpackPhase = ''
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/bin $out/opt
      mv NTPROM.RAW $out/opt/

      cat > $out/bin/winnt-mips <<EOF
      #!/bin/sh
      set -e

      ROOTDIR="\$HOME/.local/share/winnt-mips"
      mkdir -p "\$ROOTDIR"
      exec ${pkgs.qemu}/bin/qemu-system-mips64el \
        -hda "\$ROOTDIR/ntmips.img" \
        -M magnum \
        -nic user,model=dp83932 \
        -m 128 \
        -global "ds1225y.filename=\$ROOTDIR/nvram" \
        -global "ds1225y.size=8200" \
        -bios $out/opt/NTPROM.RAW \
        "\$@"
      EOF

      chmod +x $out/bin/winnt-mips
    '';
  };
in
{
  home.file.".pcem/roms".source = pkgs.fetchFromGitHub {
    owner = "BaRRaKudaRain";
    repo = "PCem-ROMs";
    rev = "v17.0";
    sha256 = "sha256-pAKxoATSYmwpNYy5WAIQmKYuAEE9INBsswvmKLuJ+50=";
  };

  home.packages = with pkgs; [
    dosbox
    pcem
    winntMips
  ];
}
