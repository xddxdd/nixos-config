{ config, ... }@args:
{
  config.services.pipewire.extraConfig.pipewire = {
    "51-combined-sink-alsa.conf" = {
      "context.modules" = [
        {
          name = "libpipewire-module-combine-stream";
          args = {
            "combine.mode" = "sink";
            "node.name" = "combine_sink_alsa";
            "node.description" = "Combined Sink for ALSA devices";
            "combine.latency-compensate" = true;
            "combine.props"."audio.position" = [
              "FL"
              "FR"
            ];
            "stream.rules" = [
              # Network receiver
              {
                matches =
                  if (config.lantian.pipewire.latencyAdjust != { }) then
                    [
                      {
                        "media.class" = "Audio/Sink";
                        "node.name" = "~latency_adjust.*";
                      }
                    ]
                  else
                    [
                      {
                        "media.class" = "Audio/Sink";
                        "node.name" = "~alsa_output.*";
                      }
                    ];
                actions = {
                  create-stream = {
                    "combine.audio.position" = [
                      "FL"
                      "FR"
                    ];
                    "audio.position" = [
                      "FL"
                      "FR"
                    ];
                  };
                };
              }
            ];
          };
        }
      ];
    };
  };
}
