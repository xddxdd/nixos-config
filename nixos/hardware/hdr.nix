{ pkgs, ... }:
{
  environment.variables = {
    DXVK_HDR = "1";
    ENABLE_HDR_WSI = "1";
  };
  hardware.graphics.extraPackages = [ pkgs.nur-xddxdd.vk-hdr-layer ];
}
