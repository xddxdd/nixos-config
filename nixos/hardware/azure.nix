_: {
  # WireServer belongs to this VM's Azure fabric, not another Azure mesh peer.
  systemd.network.networks.eth0 = {
    routes = [
      {
        Destination = "168.63.129.16/32";
        Gateway = "_dhcp4";
        GatewayOnLink = true;
        Table = 168;
      }
    ];
    routingPolicyRules = [
      {
        To = "168.63.129.16/32";
        Table = 168;
        Priority = 100;
      }
    ];
  };

  systemd.services.waagent.serviceConfig.RestartSec = "5s";

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

  lantian.hostType = "vm";
}
