{ lib, ... }:
{
  virtualisation.vmware.host.enable = true;

  lantian.preservation.directories = [ "/etc/vmware" ];

  systemd.services =
    lib.genAttrs [ "vmware-authdlauncher" "vmware-networks" "vmware-usbarbitrator" ]
      (k: {
        serviceConfig = {
          Restart = "always";
          RestartSec = "5";
        };
      });
}
