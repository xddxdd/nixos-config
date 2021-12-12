{ inputs, stateVersion, ... }:

{ config, pkgs, ... }:

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

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
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
    };

    initExtra = import ../common/helpers/zshrc.nix { inherit config pkgs; };
  };
}
