{ pkgs, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./hardware-configuration.nix
    ./lora
  ];

  lantian.kernel = pkgs.linux_rpi4;
  boot.initrd.systemd.enableTpm2 = false;
  boot.kernelParams = [ "console=ttyAMA1,115200" ];

  environment.systemPackages = with pkgs; [
    helium-gateway-rs
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
