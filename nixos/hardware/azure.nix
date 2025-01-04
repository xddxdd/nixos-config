_: {
  services.waagent = {
    enable = true;
    settings = {
      Provisioning.Enable = false;
      ResourceDisk = {
        Format = true;
        EnableSwap = true;
        SwapSizeMB = 2048;
      };
    };
  };

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
