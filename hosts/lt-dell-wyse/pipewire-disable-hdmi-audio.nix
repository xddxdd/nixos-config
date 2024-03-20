{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextFile {
      name = "wireplumber-bluez-config";
      text = ''
        rule = {
          matches = {
            {
              { "device.name", "equals", "alsa_card.pci-0000_04_00.0" },
            },
          },
          apply_properties = {
            ["device.disabled"] = true,
          },
        }

        table.insert(alsa_monitor.rules,rule)
      '';
      destination = "/share/wireplumber/main.lua.d/51-disable-hdmi-audio.lua";
    })
  ];
}
