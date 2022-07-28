{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
lib.mkIf config.boot.isContainer {
  fileSystems."/run/agenix.d" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "relatime" "mode=755" "nosuid" "nodev" ];
  };

  networking.wireguard.interfaces = lib.mkForce { };
  networking.wg-quick.interfaces = lib.mkForce { };
}
