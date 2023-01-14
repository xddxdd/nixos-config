{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      HostKeyAlgorithms +ssh-rsa
      KexAlgorithms ^sntrup761x25519-sha512@openssh.com
      PubkeyAcceptedAlgorithms +ssh-rsa

      ForwardX11 no
      StrictHostKeyChecking no
      VerifyHostKeyDNS yes
      LogLevel ERROR
    '';

    controlPath = "none";
    forwardAgent = false;
    hashKnownHosts = false;
    userKnownHostsFile = "/dev/null";

    matchBlocks = {
      "eu.nixbuild.net" = {
        user = "root";
        port = 22;
        extraOptions = {
          "PubkeyAcceptedKeyTypes" = "ssh-ed25519";
        };
      };
      "git.lantian.pub" = lib.hm.dag.entryBefore [ "*.lantian.pub" ] {
        user = "git";
        port = 2222;
        extraOptions = {
          "HostKeyAlgorithms" = "ssh-ed25519";
          "KexAlgorithms" = "sntrup761x25519-sha512@openssh.com";
          "PubkeyAcceptedAlgorithms" = "ssh-ed25519";
        };
      };
      "localhost" = {
        port = 2222;
      };
      "*.lantian.pub" = {
        user = "root";
        port = 2222;
        extraOptions = {
          "HostKeyAlgorithms" = "ssh-ed25519";
          "KexAlgorithms" = "sntrup761x25519-sha512@openssh.com";
          "PubkeyAcceptedAlgorithms" = "ssh-ed25519";
        };
      };
      "*.illinois.edu" = {
        user = "yuhuixu2";
      };
      "github.com" = {
        user = "git";
      };
    };
  };
}
