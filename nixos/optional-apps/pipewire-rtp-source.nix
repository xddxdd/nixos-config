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
              "audio.format" = "S16BE";
              "audio.rate" = 48000;
              "audio.channels" = 2;
              "audio.position" = [
                "FL"
                "FR"
              ];
              "stream.props" = {
                "media.class" = "Audio/Source";
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
