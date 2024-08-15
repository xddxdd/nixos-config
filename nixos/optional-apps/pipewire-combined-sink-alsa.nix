{ pkgs, config, ... }@args:
{
  config.services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-combined-sink-alsa";
      text = builtins.toJSON {
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
                  matches = [
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
      destination = "/share/pipewire/pipewire.conf.d/combined-sink-alsa.conf";
    })
  ];
}
