{ config, pkgs, ... }:

{
  # services.fail2ban = {
  #   enable = true;
  #   bantime-increment.enable = true;
  #   maxretry = 5;
  # };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    permitRootLogin = "prohibit-password";
    ports = [ 2222 ];
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
