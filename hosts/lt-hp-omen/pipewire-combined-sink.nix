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
                # Physical speakers
                {
                  matches = [
                    {
                      "media.class" = "Audio/Sink";
                      "node.name" = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink";
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
