{
  pkgs,
  LT,
  lib,
  config,
  ...
}:
let
  managedPrefix = LT.constants.interfacePrefixes.WAN ++ [ "nm-" ];
in
{
  preservation.preserveAt."/nix/persistent" = {
    directories = builtins.map LT.preservation.mkFolder [ "/etc/NetworkManager/system-connections" ];
  };

  hardware.wirelessRegulatoryDatabase = true;

  networking.networkmanager = {
    enable = true;
    enableStrongSwan = true;
    dns = "default";
    insertNameservers = lib.optionals config.services.coredns.enable [
      config.lantian.netns.coredns-client.ipv4
    ];
    unmanaged =
      let
        unmanagedConfig = builtins.concatStringsSep "," (
          [ "interface-name:*" ] ++ builtins.map (n: "except:interface-name:${n}*") managedPrefix
        );
      in
      [ unmanagedConfig ];
    wifi = {
      backend = "iwd";
      powersave = true;
    };
    settings.main.rc-manager = "resolvconf";

    dispatcherScripts = [
      {
        type = "basic";
        source = pkgs.writeShellScript "coredns" ''
          echo "Reloading CoreDNS"
          ${pkgs.systemd}/bin/systemctl reload coredns.service
        '';
      }
    ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  users.users.lantian.extraGroups = [ "networkmanager" ];
}
