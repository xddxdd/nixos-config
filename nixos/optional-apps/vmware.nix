{ LT, ... }:
{
  virtualisation.vmware.host.enable = true;

  preservation.preserveAt."/nix/persistent" = {
    directories = builtins.map LT.preservation.mkFolder [ "/etc/vmware" ];
  };

  fileSystems."/etc/vmware".neededForBoot = true;
}
