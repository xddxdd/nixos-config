{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextFile {
      name = "wireplumber-bluez-config";
      text = ''
        bluez_monitor.properties = {
        	["bluez5.enable-sbc-xq"] = true,
        	["bluez5.enable-msbc"] = true,
        	["bluez5.enable-hw-volume"] = true,
        	["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
      destination = "/share/wireplumber/bluetooth.lua.d/51-bluez-config.lua";
    })
  ];
}
