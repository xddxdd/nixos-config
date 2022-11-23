{ pkgs, lib, config, utils, inputs, ... }@args:

{
  xdg.configFile."psd/psd.conf".text = ''
    # https://github.com/graysky2/profile-sync-daemon/blob/master/common/psd.conf
    USE_OVERLAYFS="yes"
    USE_SUSPSYNC="yes"
    USE_BACKUPS="yes"
    BACKUP_LIMIT=1
  '';
}
