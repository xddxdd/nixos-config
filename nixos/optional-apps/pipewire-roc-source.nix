args: {
  config.services.pipewire.extraConfig.pipewire = {
    "50-roc-source.conf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-roc-source";
          args = {
            "local.ip" = "0.0.0.0";
            "local.source.port" = 10001;
            "local.repair.port" = 10002;
            "local.control.port" = 10003;
            "fec.code" = "rs8m";
            "resampler.profile" = "high";
            "sess.latency.msec" = 10;
            "source.name" = "ROC Source";
            "source.props" = {
              "node.name" = "roc-source";
              "node.description" = "ROC Source";
              "media.class" = "Stream/Output/Audio";
            };
          };
        }
      ];
    };
  };
}
