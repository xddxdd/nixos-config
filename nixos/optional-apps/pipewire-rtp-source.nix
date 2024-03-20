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
  options.lantian.pipewire-rtp-source-ifname = lib.mkOption {
    type = lib.types.str;
    default = "eth0";
  };

  config.services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-rtp-source";
      text = builtins.toJSON {
        "context.modules" = [
          {
            name = "libpipewire-module-rtp-source";
            args = {
              "source.ip" = "224.0.0.56";
              "source.port" = LT.port.PipewireRTP;
              "local.ifname" = config.lantian.pipewire-rtp-source-ifname;
              "sess.media" = "audio";
              "stream.props" = {
                "media.class" = "Stream/Output/Audio";
                "node.name" = "rtp-source";
                "node.description" = "RTP Source";
              };
            };
          }
        ];
      };
      destination = "/share/pipewire/pipewire.conf.d/rtp-source.conf";
    })
  ];
}
