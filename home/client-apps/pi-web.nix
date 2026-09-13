{
  config,
  LT,
  lib,
  osConfig,
  pkgs,
  ...
}:
lib.mkIf (osConfig.networking.hostName == "lt-hp-omen" && config.home.username == "lantian") {
  systemd.user.services.pi-web = {
    Unit = {
      Description = "Pi Web";
      After = [ "network.target" ];
    };

    Service = {
      Environment = [
        "PORT=${LT.portStr.PiWeb}"
        "PI_WEB_HOSTNAME=127.0.0.1"
        "PI_WEB_NO_OPEN=1"
        "PI_WEB_ALLOWED_HOSTS=pi-web.localhost"
      ];
      ExecStart = lib.getExe pkgs.nur-xddxdd.pi-web;
      Restart = "always";
      RestartSec = "5";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
