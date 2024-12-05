_: {
  services.pipewire.extraConfig.pipewire = {
    "50-zeroconf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-zeroconf-discover";
          args = { };
        }
      ];
    };
  };
}
