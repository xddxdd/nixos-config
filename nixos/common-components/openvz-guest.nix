{ pkgs, lib, LT, config, utils, inputs, ... }@args:

lib.mkIf config.boot.isContainer {
  fileSystems."/run/agenix.d" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "relatime" "mode=755" "nosuid" "nodev" ];
  };

  networking.wireguard.interfaces = lib.mkForce { };
  networking.wg-quick.interfaces = lib.mkForce { };

  systemd.services.yggdrasil.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "root";
  };

  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = lib.mkForce [
    "" # clear old command
    "${pkgs.coreutils}/bin/true"
  ];
}
