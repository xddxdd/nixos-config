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
                # Network receiver
                {
                  matches = [
                    {
                      "media.class" = "Audio/Sink";
                      "node.name" = "~roc-sink-.*";
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
