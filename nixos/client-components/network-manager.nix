{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  managedPrefix = LT.constants.wanInterfacePrefixes ++ [
    "nm-"
  ];
in
{
  environment.persistence."/nix/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };

  environment.systemPackages = with pkgs; [ iw ];

  networking.networkmanager =
    let
      unmanagedConfig = builtins.concatStringsSep "," ([
        "interface-name:*"
      ] ++ builtins.map (n: "except:interface-name:${n}*") managedPrefix);
    in
    {
      enable = true;
      dns = "none";
      unmanaged = [ unmanagedConfig ];
    };

  users.users.lantian.extraGroups = [ "networkmanager" ];
}
