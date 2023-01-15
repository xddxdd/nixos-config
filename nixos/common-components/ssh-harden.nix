{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  programs.ssh = {
    package = pkgs.openssh_hpn.overrideAttrs (old: {
      doCheck = false;
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
        ../../patches/openssh-disable-chroot-permission-check.patch
      ];
    });

    knownHosts = builtins.listToAttrs (lib.flatten (lib.mapAttrsToList
      (n: v:
        (lib.optional ((LT.hosts."${n}".ssh.rsa or "") != "") {
          name = "${n}-rsa";
          value = {
            hostNames = [ "${n}.lantian.pub" "${n}.xuyh0120.win" ];
            publicKey = LT.hosts."${n}".ssh.rsa;
          };
        })
        ++ (lib.optional ((LT.hosts."${n}".ssh.ed25519 or "") != "") {
          name = "${n}-ed25519";
          value = {
            hostNames = [ "${n}.lantian.pub" "${n}.xuyh0120.win" ];
            publicKey = LT.hosts."${n}".ssh.ed25519;
          };
        })
      )
      LT.hosts));
  };

  services.openssh = {
    enable = true;
    logLevel = "ERROR";
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
