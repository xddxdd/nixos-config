{
  pkgs,
  inputs,
  config,
  ...
}:
{
  sops.secrets.attic-upload-key.sopsFile = inputs.secrets + "/common/attic.yaml";

  systemd.services.attic-watch-store = {
    description = "Attic auto upload artifacts";
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.attic-client ];

    environment.HOME = "/var/cache/attic-watch-store";

    script = ''
      attic login --set-default lantian https://attic.colocrossing.xuyh0120.win $(cat ${config.sops.secrets.attic-upload-key.path})
      exec attic watch-store lantian
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      CacheDirectory = "attic-watch-store";
      WorkingDirectory = "/var/cache/attic-watch-store";
    };
  };
}
