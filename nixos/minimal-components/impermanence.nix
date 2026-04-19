{
  lib,
  config,
  ...
}:
let
  isBtrfsRoot = (config.fileSystems."/nix".fsType or "") == "btrfs";

  commonArgs = {
    configureParent = true;
  };

  mkFolders = builtins.map (mkFolder' { });
  mkFolder' =
    a: f:
    let
      directory = if builtins.isAttrs f then f.directory else f;
      attrs =
        (if builtins.isAttrs f then f else { directory = f; })
        // (lib.optionalAttrs (lib.hasPrefix "/etc/" directory) {
          how = "symlink";
          createLinkTarget = true;
        });
    in
    attrs // commonArgs // a;

  mkFiles = builtins.map (mkFile' { });
  mkFile' =
    a: f:
    let
      file = if builtins.isAttrs f then f.file else f;
      attrs =
        (if builtins.isAttrs f then f else { file = f; })
        // (lib.optionalAttrs (lib.hasPrefix "/etc/" file) {
          how = "symlink";
          createLinkTarget = true;
        });
    in
    attrs // commonArgs // a;
in
{
  options.lantian.preservation = {
    directories = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
    };
    files = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
    };
  };

  config = {
    lantian.preservation = {
      directories = [
        "/var/lib"
        "/var/log"
        "/var/www"
      ]
      ++ lib.optionals (!(config.fileSystems ? "/var/cache")) [
        "/var/cache"
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
      ];
    };

    preservation.enable = true;
    preservation.preserveAt."/nix/persistent" = {
      commonMountOptions = [
        "x-gvfs-hide"
        "x-gdu.hide"
      ];
      directories = mkFolders config.lantian.preservation.directories;
      files = mkFiles config.lantian.preservation.files;
    };

    sops.age.sshKeyPaths = [ "/nix/persistent/etc/ssh/ssh_host_ed25519_key" ];

    fileSystems = {
      "/" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "relatime"
          "mode=755"
          "nosuid"
          "nodev"
          "size=80%"
        ];
      };
    };

    services.btrfs.autoScrub = lib.mkIf isBtrfsRoot {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/nix" ];
    };
  };
}
