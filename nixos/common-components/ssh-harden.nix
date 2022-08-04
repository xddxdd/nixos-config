{ config, pkgs, lib, ... }:

{
  programs.ssh.package = pkgs.openssh_hpn.overrideAttrs (old: {
    doCheck = false;
    patches = (old.patches or []) ++ [
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
      ../../patches/openssh-disable-chroot-permission-check.patch
    ];
  });

  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkForce "prohibit-password";
    ports = [ 2222 ];
    sftpServerExecutable = "internal-sftp";
    ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
      "aes128-gcm@openssh.com"
    ];
    kexAlgorithms = [
      "sntrup761x25519-sha512@openssh.com"
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
    ];
    macs = [
      "hmac-sha2-512"
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256"
      "hmac-sha2-256-etm@openssh.com"
    ];
  };
}
