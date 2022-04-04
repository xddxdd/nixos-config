{ config, pkgs, lib, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

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

  programs.ssh = {
    enable = true;
    extraConfig = ''
      HostkeyAlgorithms +ssh-rsa
      PubkeyAcceptedAlgorithms +ssh-rsa

      StrictHostKeyChecking no
      VerifyHostKeyDNS yes
      LogLevel ERROR
    '';

    controlPath = "none";
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

    autocd = true;
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      path = "$ZDOTDIR/.zsh_history";
    };

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        # Disable zsh permission check
        export ZSH_DISABLE_COMPFIX=true
      '';
      plugins = [
        "adb"
        "gitignore"
        "nvm"
        "pip"
        "screen"
      ];
    };

    initExtra = ''
      if [ "$TERM_PROGRAM" != "vscode" ]; then
        export EDITOR="nano"
      else
        export EDITOR="code --wait"
      fi

      ########################################
      # https://wiki.archlinux.org/title/Color_output_in_console
      ########################################
      alias diff='diff --color=auto'
      alias grep='grep --color=auto'
      alias ip='ip -color=auto'
      export LESS='-R --use-color -Dd+r$Du+b'
      alias ls='ls --color=auto'
      export MANPAGER="less -R --use-color -Dd+r -Du+b"

      ########################################
      # Powerlevel10k config
      ########################################
      POWERLEVEL9K_PROMPT_ON_NEWLINE=true
      POWERLEVEL9K_DISABLE_RPROMPT=true
      POWERLEVEL9K_STATUS_VERBOSE=false
      POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""
      POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=""
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time status dir_writable nix_shell vcs context anaconda dir_joined)
      POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
      POWERLEVEL9K_CONTEXT_TEMPLATE="%n @ %m"
      if [ "$USER" = "root" ]; then
        POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{red}%F{white} # %k%f "
        POWERLEVEL9K_TIME_FOREGROUND='white'
        POWERLEVEL9K_TIME_BACKGROUND='red'
      else
        POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{white}%F{black} $ %k%f "
      fi

      ########################################
      # zsh-autosuggestions config
      ########################################
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80

      ########################################
      # zsh-syntax-highlighting config
      ########################################
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

      ########################################
      # Import scripts
      ########################################
      [[ -f "/etc/profile" ]] && emulate sh -c 'source /etc/profile'
      source ${pkgs.vte}/etc/profile.d/vte.sh
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
      source ${pkgs.zsh-bd}/share/zsh-bd/bd.zsh
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      # zsh-syntax-highlighting must be loaded last
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };

  xdg.configFile = {
    "htop/htoprc".source = ../files/htoprc;
    "nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };
}
