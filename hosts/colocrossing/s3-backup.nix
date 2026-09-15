{
  pkgs,
  inputs,
  config,
  ...
}:
{
  sops.secrets.s3fs-telnyx-secret.sopsFile = inputs.secrets + "/s3fs.yaml";

  system.fsPackages = [ pkgs.s3fs ];
  fileSystems."/mnt/telnyx-gitea" = {
    device = "lantian-gitea";
    fsType = "s3fs";
    noCheck = true;
    options = [
      "_netdev"
      "x-systemd.requires=sops-install-secrets.service"
      "ro"
      "use_path_request_style"
      "host=https://us-west-1.telnyxstorage.com"
      "region=us-west-1"
      "passwd_file=${config.sops.secrets.s3fs-telnyx-secret.path}"
      "umask=0277"
    ];
  };

  lantian.backup.paths = {
    telnyx-gitea.backupPath = "/mnt/telnyx-gitea";
  };
}
