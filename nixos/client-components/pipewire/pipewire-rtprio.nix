{ lib, ... }:
let
  # Change default.nix as well
  realtimeLimitUS = 5000000;
in
{
  services.pipewire.extraConfig =
    lib.genAttrs
      [
        "client"
        "jack"
        "pipewire-pulse"
        "pipewire"
      ]
      (_: {
        "00-rtprio" = {
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              args = {
                "nice.level" = -11;
                "rt.prio" = 99;
                "rt.time.soft" = realtimeLimitUS;
                "rt.time.hard" = realtimeLimitUS;
              };
              flags = [
                "ifexists"
                "nofail"
              ];
            }
          ];
        };
      });
}
