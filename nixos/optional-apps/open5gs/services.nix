{ pkgs, lib, ... }:
let
  services = [
    "amf"
    "ausf"
    "bsf"
    "hss"
    "mme"
    "nrf"
    "nssf"
    "pcf"
    "pcrf"
    "scp"
    "sepp"
    "sgwc"
    "sgwu"
    "smf"
    "udm"
    "udr"
    "upf"
  ];
in
{
  systemd.services = builtins.listToAttrs (
    builtins.map (svc: {
      name = "open5gs-${svc}d";
      value = {
        description = "Open5GS ${lib.toUpper svc} Daemon";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "mongodb.service"
        ];
        requires = [
          "network.target"
          "mongodb.service"
        ];
        serviceConfig = {
          ExecStart = "${pkgs.open5gs}/bin/open5gs-${svc}d -c /etc/open5gs/${svc}.yaml";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          LogsDirectory = "open5gs";
          User = "open5gs";
          Group = "open5gs";
          Restart = "always";
          RestartSec = "5";
          RestartPreventExitStatus = "1";
        };
      };
    }) services
  );

  users.users.open5gs = {
    group = "open5gs";
    isSystemUser = true;
  };
  users.groups.open5gs = { };
}
