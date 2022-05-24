{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  environment.persistence."/nix/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  environment.systemPackages = with pkgs; [ iw ];

  networking.networkmanager = {
    enable = true;
    dns = "none";
    unmanaged = [ "interface-name:*,except:interface-name:eth*,except:interface-name:wlan*,except:interface-name:nm-*" ];
  };

  users.users.lantian.extraGroups = [ "networkmanager" ];
}
