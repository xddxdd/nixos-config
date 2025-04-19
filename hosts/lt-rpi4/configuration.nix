{ pkgs, ... }:
{
  imports = [
    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/common-apps/nginx
    ../../nixos/minimal.nix

    ../../nixos/optional-apps/dump1090.nix
    ../../nixos/optional-apps/dump978.nix
    ../../nixos/optional-apps/flightradar24.nix

    ./hardware-configuration.nix
    ./lora
  ];

  # GPIO doesn't work with mainline kernel
  lantian.kernel = pkgs.linux_rpi4;

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
