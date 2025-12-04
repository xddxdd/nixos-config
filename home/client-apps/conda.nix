_: {
  xdg.configFile."conda/.condarc".text = builtins.toJSON {
    channels = [
      "conda-forge"
      "defaults"
    ];
    channel_priority = "strict";
  };
}
