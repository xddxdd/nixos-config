# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  programs.ssh = {
    ciphers = [
      "chacha20-poly1305@openssh.com"
      "aes256-gcm@openssh.com"
      "aes128-gcm@openssh.com"
      "aes256-ctr"
      "aes192-ctr"
      "aes128-ctr"
    ];
    hostKeyAlgorithms = [
      "ssh-ed25519"
      "ssh-ed25519-cert-v01@openssh.com"
      "sk-ssh-ed25519@openssh.com"
      "sk-ssh-ed25519-cert-v01@openssh.com"

      "ecdsa-sha2-nistp521"
      "ecdsa-sha2-nistp521-cert-v01@openssh.com"
      "ecdsa-sha2-nistp384"
      "ecdsa-sha2-nistp384-cert-v01@openssh.com"
      "ecdsa-sha2-nistp256"
      "ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "sk-ecdsa-sha2-nistp256@openssh.com"
      "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
      "webauthn-sk-ecdsa-sha2-nistp256@openssh.com"

      "ssh-rsa"
      "ssh-rsa-cert-v01@openssh.com"
      "rsa-sha2-512"
      "rsa-sha2-512-cert-v01@openssh.com"
      "rsa-sha2-256"
      "rsa-sha2-256-cert-v01@openssh.com"
    ];
    kexAlgorithms = [
      "sntrup761x25519-sha512@openssh.com"
      "curve25519-sha256"
      "curve25519-sha256@libssh.org"
      "ecdh-sha2-nistp521"
      "ecdh-sha2-nistp384"
      "ecdh-sha2-nistp256"
      "diffie-hellman-group14-sha256"
      "diffie-hellman-group16-sha512"
      "diffie-hellman-group18-sha512"
      "diffie-hellman-group-exchange-sha256"
    ];
    macs = [
      "hmac-sha2-512"
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256"
      "hmac-sha2-256-etm@openssh.com"
      "hmac-sha1-96"
      "hmac-sha1-96-etm@openssh.com"
      "hmac-sha1"
      "hmac-sha1-etm@openssh.com"
    ];
  };

  # services.fail2ban = {
  #   enable = true;
  #   bantime-increment.enable = true;
  #   maxretry = 5;
  # };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    startWhenNeeded = true;
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
