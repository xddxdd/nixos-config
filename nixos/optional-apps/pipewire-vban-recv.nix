args: {
  config.services.pipewire.extraConfig.pipewire = {
    "50-vban-recv.conf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-vban-recv";
          args = {
            "sess.latency.msec" = 10;
            "audio.format" = "S24LE";
            "audio.rate" = 44100;
            "source.name" = "VBAN Receiver";
            "source.props" = {
              "node.name" = "vban-recv";
              "node.description" = "VBAN Receiver";
              "media.class" = "Stream/Output/Audio";
            };
          };
        }
      ];
    };
  };
}
