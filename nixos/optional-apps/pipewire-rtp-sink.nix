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
  options.lantian.pipewire-rtp-sink-ifname = lib.mkOption {
    type = lib.types.str;
    default = "eth0";
  };

  config.services.pipewire.configPackages = [
    (pkgs.writeTextFile {
      name = "pipewire-rtp-sink";
      text = builtins.toJSON {
        "context.modules" = [
          {
            name = "libpipewire-module-rtp-sink";
            args = {
              "source.ip" = "0.0.0.0";
              "destination.ip" = "224.0.0.56";
              "destination.port" = LT.port.Pipewire.RTP;
              "local.ifname" = config.lantian.pipewire-rtp-sink-ifname;
              "net.mtu" = 1280;
              # Traverse VLANs through gateway if necessary
              "net.ttl" = 2;
              "sess.name" = "PipeWire RTP stream";
              "sess.media" = "audio";
              "stream.props" = {
                "media.class" = "Audio/Sink";
                "node.name" = "rtp-sink";
                "node.description" = "RTP Sink";
              };
            };
          }
        ];
      };
      destination = "/share/pipewire/pipewire.conf.d/rtp-sink.conf";
    })
  ];
}
