{
  pkgs,
  lib,
  LT,
  config,
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

  lantian.nginxVhosts = {
    "volume.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://unix:/run/pipewire-volume-control/listen.sock";
      };

      sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
    "volume.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://unix:/run/pipewire-volume-control/listen.sock";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
