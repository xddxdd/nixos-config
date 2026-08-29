{
  pkgs,
  lib,
  LT,
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

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe pipewire-volume-control} --listen /run/pipewire-volume-control/listen.sock";
      Restart = "always";
      RestartSec = "3";

      RuntimeDirectory = "pipewire-volume-control";
      WorkingDirectory = "/run/pipewire-volume-control";

      # Requires access to $HOME/.config/pulse/cookie
      User = "lantian";
      Group = "lantian";
      UMask = "0000";
    };
  };

  lantian.localVhosts.volume = {
    locations."/" = {
      proxyPass = "http://unix:/run/pipewire-volume-control/listen.sock";
    };
  };
}
