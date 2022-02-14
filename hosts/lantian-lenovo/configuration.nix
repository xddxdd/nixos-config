{ config, pkgs, ... }:

let
  LT = import ../../helpers { inherit config pkgs; };
in
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/resilio.nix
  ];

  environment.persistence."/nix/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  networking.networkmanager = {
    enable = true;
    unmanaged = [ "interface-name:*,except:interface-name:eth*,except:interface-name:wlan*,except:interface-name:nm-*" ];
  };

  # Disable suspend on lid close
  services.upower.ignoreLid = true;
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  services.yggdrasil.config.Peers = LT.yggdrasil [ "united-states" "canada" ];
}
