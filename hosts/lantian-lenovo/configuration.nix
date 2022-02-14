{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
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

  lantian.nginx-proxy.enable = pkgs.lib.mkForce false;
  services.coredns.enable = pkgs.lib.mkForce false;
  services.knot.enable = pkgs.lib.mkForce false;
  services.nginx.enable = pkgs.lib.mkForce false;
  services.pdns-recursor.enable = pkgs.lib.mkForce false;
}
