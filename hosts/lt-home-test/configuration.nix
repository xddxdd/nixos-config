{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../../nixos/client.nix

    ./hardware-configuration.nix

    ../../nixos/optional-apps/ollama.nix
    ../../nixos/optional-apps/opencl.nix
    ../../nixos/optional-apps/sunshine.nix
  ];

  networking.networkmanager.enable = lib.mkForce false;

  systemd.network.networks.eth0 = {
    address = [ "192.168.1.13/24" ];
    gateway = [ "192.168.1.1" ];
    matchConfig.Name = "eth0";
    linkConfig.MTUBytes = "9000";
    networkConfig.IPv6AcceptRA = "yes";
    ipv6AcceptRAConfig = {
      Token = "::13";
      DHCPv6Client = "no";
    };
    routes = [
      {
        Destination = "64:ff9b::/96";
        Gateway = "_ipv6ra";
      }
    ];
  };

  # Auto mount samba share
  age.secrets.samba-credentials.file = inputs.secrets + "/samba-credentials.age";
  fileSystems."/mnt/share" = {
    device = "//192.168.1.10/storage";
    fsType = "cifs";
    options = [
      "_netdev"
      "credentials=${config.age.secrets.samba-credentials.path}"
      "gid=${builtins.toString config.users.groups.lantian.gid}"
      "noauto"
      "uid=${builtins.toString config.users.users.lantian.uid}"
      "users"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5s"
    ];
  };
}
