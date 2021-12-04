{ config, pkgs, modulesPath, ... }:

{
  environment.persistence."/nix/persistent" = {
    directories = [
      "/var"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/tinc/ltmesh/ed25519_key.priv"
      "/etc/tinc/ltmesh/rsa_key.priv"
    ];
  };

  age.sshKeyPaths = [ "/nix/persistent/etc/ssh/ssh_host_ed25519_key" ];

  fileSystems."/var".neededForBoot = true;

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "relatime" "mode=755" "nosuid" "noexec" "nodev" ];
  };
}
