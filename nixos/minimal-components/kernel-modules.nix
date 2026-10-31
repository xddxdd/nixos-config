{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    # Blacklist kernel modules vulnerable to Dirty Frag (CVE-2025-XXXX)
    # https://github.com/V4bel/dirtyfrag
    # Using extraModprobeConfig instead of blacklistedKernelModules to also
    # override the install command, preventing accidental/manual loading.
    extraModprobeConfig = ''
      blacklist esp4
      install esp4 ${lib.getExe' pkgs.coreutils "true"}
      blacklist esp6
      install esp6 ${lib.getExe' pkgs.coreutils "true"}
      blacklist rxrpc
      install rxrpc ${lib.getExe' pkgs.coreutils "true"}
      blacklist rds
      install rds ${lib.getExe' pkgs.coreutils "true"}
      blacklist rds_tcp
      install rds_tcp ${lib.getExe' pkgs.coreutils "true"}
    ''
    # Disable algif_aead kernel module due to the "Copy-on-Write on Demand" vulnerability:
    # https://copy.fail/
    + lib.optionalString (!config.networking.networkmanager.enable) ''
      blacklist algif_aead
      install algif_aead ${lib.getExe' pkgs.coreutils "true"}
    '';

    # Crypto providers are requested dynamically, outside modules.dep.
    availableKernelModules = [
      "aes"
      "bfq"
      "cbc"
      "chacha"
      "chacha20poly1305"
      "ctr"
      "ecb"
      "fuse"
      "gcm"
      "ghash"
      "polyval"
      "xts"
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ "adios" ]
    ++ lib.optionals config.zramSwap.enable [
      "zram"
      "zstd"
    ]
    ++ lib.optional (lib.any (swap: swap.randomEncryption.enable) config.swapDevices) "dm_crypt"
    # Stage-2 mounts do not automatically add roots to a pruned module tree.
    ++ lib.concatLists (
      lib.mapAttrsToList
        (fs: modules: lib.optionals (config.boot.supportedFilesystems.${fs} or false) modules)
        {
          btrfs = [ "btrfs" ];
          ext2 = [ "ext2" ];
          ext3 = [ "ext4" ];
          ext4 = [ "ext4" ];
          f2fs = [ "f2fs" ];
          nfs = [
            "nfs"
            "nfsv3"
            "nfsv4"
          ];
          nfs4 = [ "nfsv4" ];
          ntfs3 = [ "ntfs3" ];
          ocfs2 = [ "ocfs2" ];
          squashfs = [ "squashfs" ];
          udf = [ "udf" ];
          vfat = [
            "vfat"
            "nls_ascii"
            "nls_cp437"
            "nls_iso8859_1"
          ];
          xfs = [ "xfs" ];
        }
    );

    kernelModules = [
      "cryptodev"
      "emperors-scepter"
      # Temporarily disabled for build failure
      # "nft_fullcone"
      # "ovpn-dco"
    ]
    ++ lib.optional (config.boot.supportedFilesystems.nullfsvfs or false) "nullfsvfs"
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ "ntsync" ];

    extraModulePackages = with config.boot.kernelPackages; [
      cryptodev
      emperors-scepter
      nullfsvfs
      nft-fullcone
      r8125
      r8168
    ];

    initrd = {
      availableKernelModules = [
        "hid_generic"
        "usbhid"
        "xhci_pci"
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
        "ehci_pci"
        "uhci_hcd"
      ];
      kernelModules = lib.optional (config.boot.supportedFilesystems.nullfsvfs or false) "nullfsvfs";
    };
  };
}
