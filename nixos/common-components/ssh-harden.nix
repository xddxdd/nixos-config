{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  ltnetSSHConfig = ''
    Port 2222
    HostKeyAlgorithms ssh-ed25519
    KexAlgorithms sntrup761x25519-sha512@openssh.com
    Ciphers aes256-gcm@openssh.com
    PubkeyAcceptedAlgorithms ssh-ed25519
  '';
in {
  programs.ssh = {
    package = pkgs.openssh_hpn.overrideAttrs (old: {
      doCheck = false;
      patches =
        (old.patches or [])
        ++ [
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
      (
        n: v: let
          hostNames = [
            "${n}.lantian.pub"
            "[${n}.lantian.pub]:2222"
            "${n}.xuyh0120.win"
            "[${n}.xuyh0120.win]:2222"
          ];
        in
          (lib.optional ((LT.hosts."${n}".ssh.rsa or "") != "") {
            name = "${n}-rsa";
            value = {
              inherit hostNames;
              publicKey = LT.hosts."${n}".ssh.rsa;
            };
          })
          ++ (lib.optional ((LT.hosts."${n}".ssh.ed25519 or "") != "") {
            name = "${n}-ed25519";
            value = {
              inherit hostNames;
              publicKey = LT.hosts."${n}".ssh.ed25519;
            };
          })
      )
      LT.hosts));
  };

  services.openssh = {
    enable = true;
    ports = [2222];
    sftpServerExecutable = "internal-sftp";
    settings = {
      LogLevel = "ERROR";
      PermitRootLogin = lib.mkForce "prohibit-password";
      Ciphers = [
        "aes256-gcm@openssh.com"
        "chacha20-poly1305@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      KexAlgorithms = [
        "sntrup761x25519-sha512@openssh.com"
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      Macs = [
        "hmac-sha2-512"
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256"
        "hmac-sha2-256-etm@openssh.com"
      ];
    };
  };

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      User root
      Port 22
      PubkeyAcceptedKeyTypes ssh-ed25519

    Host git.lantian.pub
      User git
      ${ltnetSSHConfig}

    Host *.lantian.pub
      User root
      ${ltnetSSHConfig}

    Host localhost
      ${ltnetSSHConfig}

    Host *
      ForwardAgent no
      Compression no
      ServerAliveInterval 0
      ServerAliveCountMax 3
      HashKnownHosts no
      UserKnownHostsFile /dev/null
      ControlMaster no
      ControlPath none
      ControlPersist no

      HostKeyAlgorithms +ssh-rsa
      KexAlgorithms ^sntrup761x25519-sha512@openssh.com
      PubkeyAcceptedAlgorithms +ssh-rsa

      StrictHostKeyChecking no
      VerifyHostKeyDNS yes
      LogLevel ERROR
  '';
}
