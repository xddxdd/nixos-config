{
  pkgs,
  lib,
  ...
}:
let
  pipewire-volume-control = pkgs.callPackage ../../pkgs/pipewire-volume-control { };
in
{
  systemd.services.pipewire-volume-control = {
    description = "pipewire-volume-control";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      PULSE_SERVER = "unix:/run/pulse/native";
      PULSE_COOKIE = "/run/pipewire-volume-control/pulse-cookie";
      XDG_CONFIG_HOME = "/run/pipewire-volume-control";
    };

    serviceConfig = {
      ExecStart = "${lib.getExe pipewire-volume-control} --listen /run/pipewire-volume-control/listen.sock";
      Restart = "always";
      RestartSec = "3";

      RuntimeDirectory = "pipewire-volume-control";
      WorkingDirectory = "/run/pipewire-volume-control";

      # Requires access to $HOME/.config/pulse/cookie
      User = "lantian";
      Group = "lantian";
      UMask = "0000";

      BindPaths = [ "/run/pipewire-volume-control" ];
      BindReadOnlyPaths = [
        "/home/lantian/.config/pulse/cookie:/run/pipewire-volume-control/pulse-cookie"
        "/run/pulse"
      ];
    };
  };

  lantian.harden.pipewire-volume-control = {
    enable = true;
    passwd = true;
  };

  lantian.localVhosts.volume = {
    locations."/" = {
      proxyPass = "http://unix:/run/pipewire-volume-control/listen.sock";
    };
  };
}
