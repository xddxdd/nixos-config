{
  pkgs,
  lib,
  config,
  ...
}:
# Fix crashing
lib.mkIf (config.networking.hostName != "lt-dell-wyse") {
  services.pipewire.extraConfig.pipewire = {
    "50-noise-cancelling" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.name" = "rnnoise_source";
            "node.description" = "Noise Canceling source";
            "media.name" = "Noise Canceling source";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.nur-xddxdd.noise-suppression-for-voice}/lib/ladspa/librnnoise_ladspa.so";
                  label = "noise_suppressor_stereo";
                  control = {
                    "VAD Threshold (%)" = 50.0;
                    "VAD Grace Period (ms)" = 200;
                    "Retroactive VAD Grace (ms)" = 0;
                  };
                }
              ];
            };
            "capture.props" = {
              "node.passive" = true;
              "audio.rate" = 48000;
            };
            "playback.props" = {
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };
}
