{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  environment.etc."NetworkManager/dnsmasq.d/dns-forward.conf".text =
    builtins.concatStringsSep "\n"
      (lib.flatten
        ((builtins.map (n: [ "server=/${n}/172.18.0.253" "server=/${n}/fdbc:f9dc:67ad:2547::53" ])
          (with LT.constants; (dn42Zones ++ neonetworkZones ++ openNICZones ++ emercoinZones)))
        ++ [ "" ]));

  environment.persistence."/nix/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  environment.systemPackages = with pkgs; [ iw ];

  networking.networkmanager = {
    enable = true;
    dns = "dnsmasq";
    unmanaged = [ "interface-name:*,except:interface-name:eth*,except:interface-name:wlan*,except:interface-name:nm-*" ];
  };

  users.users.lantian.extraGroups = [ "networkmanager" ];
}
