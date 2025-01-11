{ pkgs, ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
    ./lora
  ];

  boot.initrd.systemd.tpm2.enable = false;

  environment.systemPackages = with pkgs; [
    nur-xddxdd.helium-gateway-rs
  ];

  systemd.network.networks.eth0 = {
    address = [ "192.168.0.6/24" ];
    gateway = [ "192.168.0.1" ];
    matchConfig.Name = "eth0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::6";
      DHCPv6Client = "no";
    };
  };
}
