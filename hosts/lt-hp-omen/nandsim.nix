{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  # drivers/mtd/nand/raw/nand_ids.c
  boot.kernelModules = ["ubi"];

  environment.systemPackages = with pkgs; [
    mtdutils
    ubi_reader
  ];
}
