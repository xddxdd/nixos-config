{ config, lib, ... }:
let
  cfg = config.lantian.pipewire.latencyAdjust;
in
{
  options = {
    lantian.pipewire.latencyAdjust = lib.mkOption {
      type = lib.types.attrsOf lib.types.number;
      default = { };
    };
  };

  config.services.pipewire.extraConfig.pipewire = lib.mkIf (cfg != { }) {
    "49-latency-adjust.conf" = {
      "context.modules" = lib.mapAttrsToList (n: v: {
        name = "libpipewire-module-loopback";
        args = {
          "node.name" = "latency_adjust_${n}";
          "node.description" = "Latency Adjustment for ${n}";
          "target.delay.sec" = v;
          "capture.props" = {
            "node.name" = "latency_adjust.${n}";
            "media.class" = "Audio/Sink";
          };
          "playback.props" = {
            "node.name" = "playback.latency_adjust.${n}";
            "media.class" = "Stream/Output/Audio";
            "target.object" = n;
          };
        };
      }) cfg;
    };
  };
}
