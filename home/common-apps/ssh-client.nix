_: {
  home.activation.remove-custom-ssh-config = ''
    if [ -f "$HOME/.ssh/config" ]; then
      rm -f $HOME/.ssh/config
    fi
  '';
}
