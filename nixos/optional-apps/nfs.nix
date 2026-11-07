{
  LT,
  lib,
  config,
  ...
}:
{

  boot.extraModprobeConfig = ''
    options nfs nfs4_disable_idmapping=1
    options nfsd nfs4_disable_idmapping=1
  '';

  # NFSv3 helper ports (statd/lockd/mountd) are LTnet-internal
  lantian.firewall.zones.LAN.tcpPorts = {
    "${LT.portStr.NFS.StatD}" = {
      type = "local";
    };
    "${LT.portStr.NFS.LockD}" = {
      type = "local";
    };
    "${LT.portStr.NFS.MountD}" = {
      type = "local";
    };
  };
  lantian.firewall.zones.LAN.udpPorts = {
    "${LT.portStr.NFS.StatD}" = {
      type = "local";
    };
    "${LT.portStr.NFS.LockD}" = {
      type = "local";
    };
    "${LT.portStr.NFS.MountD}" = {
      type = "local";
    };
  };

  services.nfs.server = {
    enable = true;
    nproc = 64;
    hostName = LT.this.ltnet.IPv4;
    lockdPort = LT.port.NFS.LockD;
    mountdPort = LT.port.NFS.MountD;
    statdPort = LT.port.NFS.StatD;

    exports = ''
      /run/nfs 198.18.0.0/24(ro,fsid=0,no_subtree_check)
    '';
  };

  systemd.services.nfs-server.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "5";
  };

  systemd.tmpfiles.settings = lib.mkIf (lib.hasInfix "/run/nfs" config.services.nfs.server.exports) {
    nfs = {
      "/run/nfs"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };
}
