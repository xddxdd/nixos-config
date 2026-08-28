{ LT, ... }:
{
  imports = [
    ../../nixos/server.nix

    ./hardware-configuration.nix
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  systemd.network.networks.eth0 = LT.cloudLanNetworking "eth0";

  lantian.ocfs2 = {
    enable = true;
    clusterName = "oci";
    heartbeatRegions = [ "5A4E80FDADBA4754972305F0C69EC3BE" ];
    nodes = [
      {
        name = "oracle-vm1";
        ip = "172.18.126.2";
        number = 0;
      }
      {
        name = "oracle-vm2";
        ip = "172.18.126.3";
        number = 1;
      }
      {
        name = "oracle-vm-arm1";
        ip = "172.18.126.16";
        number = 2;
      }
    ];
    mounts = [
      {
        mountPoint = "/mnt/ocfs";
        device = "/dev/sdb1";
      }
    ];
  };
}
