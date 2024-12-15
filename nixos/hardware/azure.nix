{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/azure-agent.nix")
  ];

  virtualisation.azure.agent.enable = true;

  boot.kernelParams = [
    "console=ttyS0"
    "earlyprintk=ttyS0"
    "rootdelay=300"
  ];
  boot.initrd.kernelModules = [
    "hv_vmbus"
    "hv_netvsc"
    "hv_utils"
    "hv_storvsc"
  ];
}
