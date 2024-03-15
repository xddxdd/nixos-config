{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
}@args:
let
  # Change default.nix as well
  realtimeLimitUS = 5000000;
in
{
  services.pipewire.configPackages =
    builtins.map
      (
        n:
        pkgs.writeTextFile {
          name = "pipewire-${n}-rtprio";
          text = builtins.toJSON {
            "context.modules" = [
              {
                name = "libpipewire-module-rt";
                args = {
                  "nice.level" = -11;
                  "rt.prio" = 88;
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
          destination = "/share/pipewire/${n}.conf.d/rtprio.conf";
        }
      )
      [
        "client-rt"
        "client"
        "jack"
        "pipewire-pulse"
        "pipewire"
      ];
}
