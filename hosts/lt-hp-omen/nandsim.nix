{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  # drivers/mtd/nand/raw/nand_ids.c
  boot.kernelModules = [ "nandsim" ];
  boot.extraModprobeConfig = ''
    options nandsim first_id_byte=0x72 parts=1024
  '';
}
