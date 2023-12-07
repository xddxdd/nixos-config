{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.hetzner-storagebox-cifs-credentials.file = inputs.secrets + "/hetzner-storagebox-cifs-credentials.age";

  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems."/mnt/storage" = {
    device = "//u378583.your-storagebox.de/backup";
    fsType = "cifs";
    options = [
      "iocharset=utf8"
      "credentials=${config.age.secrets.hetzner-storagebox-cifs-credentials.path}"
      "uid=0"
      "gid=0"
      "file_mode=0644"
      "dir_mode=0755"
      "vers=3"
      "seal"
    ];
    neededForBoot = false;
  };

  # Gitea
  systemd.services.gitea = {
    after = ["mnt-storage.mount" "var-lib-gitea-repositories.mount"];
    requires = ["mnt-storage.mount" "var-lib-gitea-repositories.mount"];
    serviceConfig.TimeoutStartSec = "900";
  };
  fileSystems."/var/lib/gitea/repositories" = {
    device = "/mnt/storage/gitea";
    depends = ["/mnt/storage"];
    fsType = "fuse.bindfs";
    options = [
      "force-user=git"
      "force-group=gitea"
      "create-for-user=root"
      "create-for-group=root"
      "chown-ignore"
      "chgrp-ignore"
      "xattr-none"
      "x-gvfs-hide"
    ];
    neededForBoot = false;
  };
}
