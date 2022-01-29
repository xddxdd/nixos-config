{ config, pkgs, ... }:

{
  environment.persistence."/nix/persistent" = {
    directories = [
      "/var/backup"
      "/var/cache"
      "/var/lib"
      "/var/log"
      "/var/www"
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

  age.identityPaths = [ "/nix/persistent/etc/ssh/ssh_host_ed25519_key" ];

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "relatime" "mode=755" "nosuid" "noexec" "nodev" ];
  };
}
