{
  LT,
  lib,
  config,
  ...
}:
let
  nfsPorts = {
    "${LT.portStr.NFS.Port}".type = "local";
    "${LT.portStr.NFS.StatD}".type = "local";
    "${LT.portStr.NFS.LockD}".type = "local";
    "${LT.portStr.NFS.MountD}".type = "local";
  };
in
{

  boot.extraModprobeConfig = ''
    options nfs nfs4_disable_idmapping=1
    options nfsd nfs4_disable_idmapping=1
  '';

  # NFS server and v3 helper ports are LAN/LTnet-internal
  lantian.firewall.zones = {
    LAN.ports = nfsPorts;
    LTNET.ports = nfsPorts;
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
