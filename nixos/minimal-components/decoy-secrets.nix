{
  config,
  pkgs,
  lib,
  ...
}:
let
  password = "${lib.getExe pkgs.pwgen} -s 48 1";
  home = config.users.users.lantian.home;
  awsCredentials = ''
    printf '[default]\naws_access_key_id = AKIA%s\naws_secret_access_key = %s\n' \
      "$(${lib.getExe pkgs.pwgen} -s 16 1 | ${lib.getExe' pkgs.coreutils "tr"} '[:lower:]' '[:upper:]')" "$(${lib.getExe pkgs.pwgen} -s 40 1)"
  '';
  decoy = path: command: {
    inherit path command;
    audit = true;
    mode = "0600";
  };
in
{
  # Keep credential backups separate from files selected by clients at runtime.
  lantian.secrets = {
    root-ssh = decoy "/root/.ssh/id_ed25519.bak" ''
      ${lib.getExe' pkgs.openssh "ssh-keygen"} -q -t ed25519 -N "" -C "root@${config.networking.hostName}" -f key
      ${lib.getExe' pkgs.coreutils "cat"} key
    '';
    root-aws = decoy "/root/.aws/credentials.bak" awsCredentials;
    root-pgpass = decoy "/root/.pgpass.bak" ''
      printf 'localhost:5432:*:postgres:%s\n' "$(${password})"
    '';
    root-mysql = decoy "/root/.my.cnf.bak" ''
      printf '[client]\nhost = localhost\nuser = root\npassword = %s\n' "$(${password})"
    '';
    root-github = decoy "/root/.config/gh/hosts.yml.bak" ''
      printf 'github.com:\n    user: xddxdd\n    oauth_token: ghp_%s\n' "$(${lib.getExe pkgs.pwgen} -s 36 1)"
    '';
    root-npm = decoy "/root/.npmrc.bak" ''
      printf '//registry.npmjs.org/:_authToken=npm_%s\n' "$(${lib.getExe pkgs.pwgen} -s 36 1)"
    '';
    backup-environment = decoy "/etc/backup/credentials.env.bak" ''
      printf 'RESTIC_REPOSITORY=s3:s3.us-west-2.amazonaws.com/${config.networking.hostName}-backups\nAWS_ACCESS_KEY_ID=AKIA%s\nAWS_SECRET_ACCESS_KEY=%s\nRESTIC_PASSWORD=%s\n' \
        "$(${lib.getExe pkgs.pwgen} -s 16 1 | ${lib.getExe' pkgs.coreutils "tr"} '[:lower:]' '[:upper:]')" \
        "$(${lib.getExe pkgs.pwgen} -s 40 1)" "$(${password})"
    '';
    user-aws = (decoy "${home}/.aws/credentials.bak" awsCredentials) // {
      owner = "lantian";
      group = config.users.users.lantian.group;
    };
  };
}
