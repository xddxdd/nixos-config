{ pkgs, ... }:
{
  home.packages = [
    pkgs.model_composer
    pkgs.vitis
    pkgs.vitis_hls
    pkgs.vivado
    pkgs.xilinx-shell
  ];

  xdg.configFile."xilinx/nix.sh".text = ''
    INSTALL_DIR=$HOME/.local/share/Xilinx
    VERSION=2024.2
  '';
}
