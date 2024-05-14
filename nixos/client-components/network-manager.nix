{ LT, ... }:
let
  managedPrefix = LT.constants.interfacePrefixes.WAN ++ [ "nm-" ];
in
{
  environment.persistence."/nix/persistent" = {
    directories = [ "/etc/NetworkManager/system-connections" ];
  };

  hardware.wirelessRegulatoryDatabase = true;

  networking.networkmanager =
    let
      unmanagedConfig = builtins.concatStringsSep "," (
        [ "interface-name:*" ] ++ builtins.map (n: "except:interface-name:${n}*") managedPrefix
      );
    in
    {
      enable = true;
      enableStrongSwan = true;
      dns = "none";
      unmanaged = [ unmanagedConfig ];
    };

  users.users.lantian.extraGroups = [ "networkmanager" ];
}
