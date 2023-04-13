{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  systemd.enableUnifiedCgroupHierarchy = true;

  systemd.services."container@k3s-server".environment = {
    SYSTEMD_NSPAWN_UNIFIED_HIERARCHY = "1";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/k3s-server 755 root root"
  ];

  containers.k3s-server = LT.container {
    name = "docker";
    ipSuffix = "230";

    outerConfig = {
      bindMounts = {
        var-lib = {
          hostPath = "/var/lib/k3s-server";
          mountPoint = "/var/lib";
          isReadOnly = false;
        };
      };
    };

    innerConfig = _: {
      services.k3s = {
        enable = true;
        role = "server";
      };
    };
  };
}
