_: {
  services.pipewire.extraConfig.pipewire = {
    "50-airplay" = {
      "context.modules" = [
        {
          name = "libpipewire-module-raop-discover";
          args = { };
        }
      ];
    };
  };
}
