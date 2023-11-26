{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.hetzner-storagebox-ssh-key.file = inputs.secrets + "/hetzner-storagebox-ssh-key.age";

  environment.systemPackages = [pkgs.sshfs];

  fileSystems."/mnt/storage" = {
    device = "u378583@u378583.your-storagebox.de:/home";
    fsType = "fuse.sshfs";
    options = [
      "allow_other"
      "idmap=user"
      "port=23"
      "reconnect"
      "IdentityFile=${config.age.secrets.hetzner-storagebox-ssh-key.path}"
    ];
    neededForBoot = true;
  };

  # Gitea
  systemd.services.gitea = {
    after = ["mnt-storage.mount" "var-lib-gitea.mount"];
    requires = ["mnt-storage.mount" "var-lib-gitea.mount"];
    serviceConfig = {
      ReadWritePaths = ["/var/lib/gitea"];
      StateDirectory = lib.mkForce "";
    };
  };
  fileSystems."/var/lib/gitea" = {
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
  };
}
