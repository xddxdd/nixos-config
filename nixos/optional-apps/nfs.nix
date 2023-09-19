{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
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
      /run/nfs 198.18.0.0/24(rw,fsid=0,no_subtree_check)
    '';
  };

  systemd.tmpfiles.rules = [
    "d /run/nfs 755 root root"
  ];
}
