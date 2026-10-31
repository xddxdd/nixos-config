{ config, lib, ... }:
{
  boot.pruneKernelModules = true;
  boot.availableKernelModules = [
    "dmi_sysfs"
    "evdev"
    "hv_balloon"
    "hv_sock"
    "hyperv_drm"
    "joydev"
    "mac_hid"
    "mousedev"
    "rtc_cmos"
    "serio_raw"
    "vmgenid"
  ];
  # waagent mounts its resource disk outside fileSystems.
  boot.supportedFilesystems = lib.optional config.services.waagent.settings.ResourceDisk.Format config.services.waagent.settings.ResourceDisk.FileSystem;
  boot.initrd.includeDefaultModules = false;
  boot.initrd.availableKernelModules = [
    "hid_hyperv"
    "hyperv_keyboard"
    "sd_mod"
  ];

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
  boot.initrd.kernelModules = {
    # Upstream waagent requests legacy ATA; these guests use Hyper-V storage.
    ata_piix = lib.mkForce false;
    hv_vmbus = true;
    hv_netvsc = true;
    hv_utils = true;
    hv_storvsc = true;
  };

  lantian.hostType = "vm";
}
