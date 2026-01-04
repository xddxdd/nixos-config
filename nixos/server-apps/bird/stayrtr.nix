{
  pkgs,
  LT,
  lib,
  ...
}:
lib.mkIf (LT.this.hasTag LT.tags.dn42) {
  systemd.services.stayrtr-rpki = {
    description = "StayRTR for DN42 RPKI";
    before = [ "bird.service" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      User = "stayrtr";
      Group = "stayrtr";

      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.stayrtr}/bin/stayrtr"
        "--bind 127.0.0.1:${LT.portStr.StayRTR.RPKI}"
        "--metrics.addr 127.0.0.1:${LT.portStr.StayRTR.Metrics.RPKI}"
        "--cache /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_stayrtr.conf"
        "--rtr.expire 86400"
        "--rtr.refresh 60"
        "--rtr.retry 60"
      ];
    };
  };

  systemd.services.stayrtr-flapalerted = {
    description = "StayRTR for FlapAlerted";
    before = [ "bird.service" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      User = "stayrtr";
      Group = "stayrtr";

      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.stayrtr}/bin/stayrtr"
        "--bind 127.0.0.1:${LT.portStr.StayRTR.FlapAlerted}"
        "--metrics.addr 127.0.0.1:${LT.portStr.StayRTR.Metrics.FlapAlerted}"
        "--cache https://flapalerted.lantian.pub/flaps/active/roa"
        "--rtr.expire 3600"
        "--rtr.refresh 60"
        "--rtr.retry 60"
      ];
    };
  };

  systemd.services.stayrtr-flap42-strexp = {
    description = "StayRTR for https://flap42-data.strexp.net";
    before = [ "bird.service" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      User = "stayrtr";
      Group = "stayrtr";

      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.stayrtr}/bin/stayrtr"
        "--bind 127.0.0.1:${LT.portStr.StayRTR.Flap42}"
        "--metrics.addr 127.0.0.1:${LT.portStr.StayRTR.Metrics.Flap42}"
        "--cache https://flap42-data.strexp.net/min_3.json"
        "--rtr.expire 3600"
        "--rtr.refresh 300"
        "--rtr.retry 300"
      ];
    };
  };

  users.users.stayrtr = {
    group = "stayrtr";
    isSystemUser = true;
  };
  users.groups.stayrtr = { };
}
