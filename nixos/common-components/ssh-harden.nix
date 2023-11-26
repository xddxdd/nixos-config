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
      configureFlags =
        (old.configureFlags or [])
        ++ [
          "--with-ssl-engine"
        ];
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

    knownHosts =
      (builtins.listToAttrs (lib.flatten (lib.mapAttrsToList
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
        LT.hosts)))
      // {
        "your-storagebox.de-rsa" = {
          hostNames = ["[u378583.your-storagebox.de]:23"];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
        };
        "your-storagebox.de-ecdsa" = {
          hostNames = ["[u378583.your-storagebox.de]:23"];
          publicKey = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGK0po6usux4Qv2d8zKZN1dDvbWjxKkGsx7XwFdSUCnF19Q8psHEUWR7C/LtSQ5crU/g+tQVRBtSgoUcE8T+FWp5wBxKvWG2X9gD+s9/4zRmDeSJR77W6gSA/+hpOZoSE+4KgNdnbYSNtbZH/dN74EG7GLb/gcIpbUUzPNXpfKl7mQitw==";
        };
        "your-storagebox.de-ed25519" = {
          hostNames = ["[u378583.your-storagebox.de]:23"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
        };
      };
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
