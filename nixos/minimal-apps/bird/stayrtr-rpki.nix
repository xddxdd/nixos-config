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

    script = ''
      exec ${pkgs.stayrtr}/bin/stayrtr \
        --bind 127.0.0.1:${LT.portStr.StayRTR.RPKI} \
        --cache /nix/persistent/sync-servers/ltnet-scripts/bird/dn42/dn42_stayrtr.conf \
        --rtr.expire 86400 \
        --rtr.refresh 600 \
        --rtr.retry 600
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      User = "stayrtr";
      Group = "stayrtr";
    };
  };

  users.users.stayrtr = {
    group = "stayrtr";
    isSystemUser = true;
  };
  users.groups.stayrtr = { };
}
