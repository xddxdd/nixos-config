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
    VERSION=$(ls -1 $INSTALL_DIR/Vivado | grep -E '^[0-9.]+$' | sort -r | head -n1)
  '';
}
