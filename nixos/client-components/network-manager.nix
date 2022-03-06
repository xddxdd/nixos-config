{ config, pkgs, ... }:

{
  environment.persistence."/nix/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  networking.networkmanager = {
    enable = true;
    unmanaged = [ "interface-name:*,except:interface-name:eth*,except:interface-name:wlan*,except:interface-name:nm-*" ];
  };

  users.users.lantian.extraGroups = [ "networkmanager" ];
}
