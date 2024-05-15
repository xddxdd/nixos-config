_: {
  virtualisation.vmware.host.enable = true;

  environment.persistence."/nix/persistent" = {
    directories = [ "/etc/vmware" ];
  };

  fileSystems."/etc/vmware".neededForBoot = true;
}
