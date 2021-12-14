{ inputs, stateVersion, ... }:

{ config, pkgs, lib, ... }:

{
  imports = [
    inputs.nixos-vscode-server.nixosModules.homeManager
  ];

  home.stateVersion = stateVersion;

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        autoCrlf = "input";
      };
      pull = {
        rebase = false;
      };
    };
    userName = "Lan Tian";
    userEmail = "xuyh0120@outlook.com";
  };

  services.auto-fix-vscode-server.enable = true;

  xdg.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
      HostkeyAlgorithms +ssh-rsa
      PubkeyAcceptedAlgorithms +ssh-rsa

      StrictHostKeyChecking no
      VerifyHostKeyDNS yes
      LogLevel ERROR
    '';

    forwardAgent = true;
    hashKnownHosts = false;
    userKnownHostsFile = "/dev/null";

    matchBlocks = {
      "git.lantian.pub" = lib.hm.dag.entryBefore [ "*.lantian.pub" ] {
        user = "git";
        # port = 22;
      };
      "*.lantian.pub" = {
        user = "root";
        port = 2222;
      };
      "*.illinois.edu" = {
        user = "yuhuixu2";
      };
      "github.com" = {
        user = "git";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableVteIntegration = true;

    autocd = true;
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      path = "$ZDOTDIR/.zsh_history";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "adb"
        "gitignore"
        "nvm"
        "pip"
        "screen"
      ];
    };

    initExtra = import ../common/helpers/zshrc.nix { inherit config pkgs; };
  };
}
