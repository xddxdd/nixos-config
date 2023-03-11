{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.kioubit-ipv6-canvas-streamer-telegram.file = inputs.secrets + "/kioubit-ipv6-canvas-streamer-telegram.age";

  systemd.services.kioubit-ipv6-canvas-streamer = {
    wantedBy = ["multi-user.target"];
    path = with pkgs; [
      bash
      (python3.withPackages (p: with p; [pillow]))
      ffmpeg_5-full
    ];
    script = ''
      TARGET=$(cat ${config.age.secrets.kioubit-ipv6-canvas-streamer-telegram.path})
      cd ${inputs.kioubit-ipv6-canvas-streamer}
      bash stream_to_telegram.sh "$TARGET"
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
    };
  };
}
