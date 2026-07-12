_: {
  home.file.".vscode/argv.json" = {
    text = builtins.toJSON {
      # Fixes the "an OS keyring couldn't be identified for storing the encryption..." error
      # https://github.com/microsoft/vscode/issues/187338#issuecomment-3708627825
      "password-store" = "gnome-libsecret";
    };
    force = true;
  };
}
