{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
{
  config.services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-combined-sink";
      text = builtins.toJSON {
        "context.modules" = [
          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "100ms latency to sync with ROC Sink";
              "target.delay.sec" = 0.1;
              "capture.props" = {
                "node.name" = "latency.sink";
                "node.description" = "100ms Latency Sink";
                "media.class" = "Stream/Input/Audio";
                "audio.position" = [
                  "FL"
                  "FR"
                ];
                "node.autoconnect" = false;
              };
              "playback.props" = {
                "node.name" = "latency.source";
                "node.description" = "100ms Latency Source";
                "node.passive" = true;
                "media.class" = "Stream/Output/Audio";
                "audio.position" = [
                  "FL"
                  "FR"
                ];
                "target.object" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink";
              };
            };
          }
          {
            name = "libpipewire-module-combine-stream";
            args = {
              "combine.mode" = "sink";
              "node.name" = "combine_sink";
              "node.description" = "Combined Sink";
              "combine.latency-compensate" = true;
              "combine.props"."audio.position" = [
                "FL"
                "FR"
              ];
              "stream.rules" = [
                # Physical speakers with latency compensation
                {
                  matches = [
                    {
                      "media.class" = "Stream/Input/Audio";
                      "node.name" = "latency.sink";
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
                # Network receiver
                {
                  matches = [
                    {
                      "media.class" = "Audio/Sink";
                      "node.name" = "roc-sink-192.168.0.207";
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
      destination = "/share/pipewire/pipewire.conf.d/combined-sink.conf";
    })
  ];
}
