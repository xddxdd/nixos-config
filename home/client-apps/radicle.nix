{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
lib.mkIf (osConfig.networking.hostName == "lt-hp-omen" && config.home.username == "lantian") {
  home.packages = [ pkgs.radicle-node ];

  systemd.user.services.radicle-node = {
    Unit = {
      Description = "Radicle node (decentralized git server)";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${lib.getExe' pkgs.radicle-node "radicle-node"} --log-logger systemd";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
