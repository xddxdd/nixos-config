{ LT, lib, ... }:
{
  virtualisation.vmware.host.enable = true;

  preservation.preserveAt."/nix/persistent" = {
    directories = LT.preservation.mkFolders [ "/etc/vmware" ];
  };

  systemd.services =
    lib.genAttrs [ "vmware-authdlauncher" "vmware-networks" "vmware-usbarbitrator" ]
      (k: {
        serviceConfig = {
          Restart = "always";
          RestartSec = "5";
        };
      });
}
