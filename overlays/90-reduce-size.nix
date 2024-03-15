{ inputs, ... }:
final: prev:
let
  patchNix =
    p:
    p.override {
      enableDocumentation = false;
      withAWS = false;
    };
in
rec {
  # Disable Nix S3 support
  nix = patchNix prev.nix;
  nixFlakes = patchNix prev.nixFlakes;
  nixStable = patchNix prev.nixStable;
  nixUnstable = patchNix prev.nixUnstable;
  nixVersions = final.lib.mapAttrs (n: v: patchNix v) prev.nixVersions;

  # Disable Oh My Zsh's compdump call
  oh-my-zsh = prev.oh-my-zsh.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../patches/oh-my-zsh-disable-compdump.patch ];
  });

  # Use single copy of OpenSSH HPN for everything
  openssh = openssh_hpn;
  openssh_hpn = prev.openssh_hpn.overrideAttrs (old: {
    doCheck = false;
    configureFlags = (old.configureFlags or [ ]) ++ [ "--with-ssl-engine" ];
    patches = (old.patches or [ ]) ++ [
      # OpenSSH requires all directories in path to chroot be writable only for
      # root, to avoid a security issue described in:
      #
      # https://lists.mindrot.org/pipermail/openssh-unix-dev/2009-May/027651.html
      #
      # It requires a suid binary to exist on the same partition as the chroot
      # target, which isn't the case on NixOS (all suid binaries are in
      # /run/wrappers).
      #
      # Disable this behavior so I can configure SFTP properly.
      ../patches/openssh-disable-chroot-permission-check.patch
    ];
  });
}
