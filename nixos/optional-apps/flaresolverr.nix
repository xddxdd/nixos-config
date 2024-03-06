{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  systemd.services.flaresolverr = {
    description = "FlareSolverr";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    wants = ["network.target"];
    path = with pkgs; [
      xorg.xorgserver
    ];
    environment = {
      HOME = "/run/flaresolverr";
      HOST = "127.0.0.1";
      PORT = LT.portStr.FlareSolverr;
      LOG_LEVEL = "warn";
    };
    serviceConfig =
      LT.serviceHarden
      // {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.flaresolverr}/bin/flaresolverr";
        RuntimeDirectory = "flaresolverr";
        WorkingDirectory = "/run/flaresolverr";

        MemoryDenyWriteExecute = false;
        SystemCallFilter = lib.mkForce [];
      };
  };
}
