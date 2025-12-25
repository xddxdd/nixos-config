{ LT, ... }:
{
  boot.extraModprobeConfig = ''
    options nfs nfs4_disable_idmapping=1
    options nfsd nfs4_disable_idmapping=1
  '';

  services.nfs.server = {
    enable = true;
    hostName = LT.this.ltnet.IPv4;
    lockdPort = LT.port.NFS.LockD;
    mountdPort = LT.port.NFS.MountD;
    statdPort = LT.port.NFS.StatD;

    exports = ''
      /run/nfs 198.18.0.0/24(ro,fsid=0,no_subtree_check)
    '';
  };

  systemd.tmpfiles.settings = {
    nfs = {
      "/run/nfs"."d" = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };
}
