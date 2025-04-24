{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    # # Unused since I'm using oh-my-zsh
    # completionInit = lib.mkForce ''
    #   autoload -U compinit && compinit -D
    # '';

    autocd = true;
    autosuggestion.enable = true;
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      path = "$ZDOTDIR/.zsh_history";
    };
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      custom = builtins.toString (
        pkgs.linkFarm "oh-my-zsh-custom" {
          "themes/powerlevel10k.zsh-theme" =
            "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          "plugins/autopair" = "${pkgs.zsh-autopair}/share/zsh/zsh-autopair";
          "plugins/bd" = "${pkgs.zsh-bd}/share/zsh-bd";
          "plugins/nix-shell" = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
          "plugins/you-should-use" = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
        }
      );
      extraConfig = ''
        # Disable zsh permission check
        export ZSH_DISABLE_COMPFIX=true

        export FZF_BASE=${pkgs.fzf}
      '';
      plugins = [
        "autopair"
        "bd"
        "fzf"
        "gitignore"
        "kubectl"
        "nix-shell"
        "pip"
        "screen"
        "you-should-use"
        "z"
      ];
      theme = "powerlevel10k";
    };

    envExtra = ''
      [[ -f "/etc/profile" ]] && emulate sh -c 'source /etc/profile'

      if [ "$TERM_PROGRAM" != "vscode" ]; then
        export EDITOR="nano"
      else
        export EDITOR="code --wait"
      fi

      alias nb="nix build -L"
      function nlw { nix-locate -w "$@" | grep -v "^(" }

      # For Podman
      export REGISTRY_AUTH_FILE="$HOME/.config/podman-registry-auth.json";

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
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time command_execution_time status dir_writable nix_shell vcs context anaconda dir_joined)
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
      # zsh-z config
      ########################################
      ZSHZ_DATA="$ZDOTDIR/.z"
      ZSHZ_EXCLUDE_DIRS=(/nix/store)
      ZSHZ_TILDE=1
      ZSHZ_TRAILING_SLASH=1
    '';

    initContent = lib.mkBefore ''
      [[ -n "$ZSH_ZPROF" ]] && zmodload zsh/zprof
    '';
  };
}
