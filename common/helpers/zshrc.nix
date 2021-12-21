{ config, pkgs, ... }:

''
  source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

  [[ -f "/usr/share/nvm/init-nvm.sh" ]] && source /usr/share/nvm/init-nvm.sh

  if [ "$TERM_PROGRAM" != "vscode" ]; then
    POWERLEVEL9K_MODE="nerdfont-complete"
  fi
  POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  POWERLEVEL9K_DISABLE_RPROMPT=true
  POWERLEVEL9K_STATUS_VERBOSE=false
  POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""
  POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=""
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time status dir_writable vcs context anaconda dir_joined)
  #POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time status dir_writable vcs context dir_joined)
  POWERLEVEL9K_SHORTEN_DIR_LENGTH=100
  #POWERLEVEL9K_SHORTEN_DELIMITER=".."
  #POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_unique"
  POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
  POWERLEVEL9K_CONTEXT_TEMPLATE="%n @ %m"
  if [ "$USER" = "root" ]; then
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{red}%F{white} # %k%f "
    POWERLEVEL9K_TIME_FOREGROUND='white'
    POWERLEVEL9K_TIME_BACKGROUND='red'
  else
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%K{white}%F{black} $ %k%f "
  fi

  # zsh-syntax-highlighting must be the last one
  source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
''
