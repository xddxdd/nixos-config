{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    ../../nixos/hardware/disable-watchdog.nix
    ../../nixos/common-apps/nginx
    ../../nixos/minimal.nix

    ../../nixos/optional-apps/adsb
    ../../nixos/optional-apps/ncps-client.nix

    ./hardware-configuration.nix
    ./lora
  ];

  # GPIO doesn't work with mainline kernel; use the Raspberry Pi vendor kernel
  # recipe from nixos-hardware (built with our own nixpkgs) instead of the
  # deprecated pkgs.linux_rpi4 alias.
  lantian.kernel = pkgs.callPackage (inputs.nixos-hardware + "/raspberry-pi/common/kernel.nix") {
    rpiVersion = 4;
  };

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
