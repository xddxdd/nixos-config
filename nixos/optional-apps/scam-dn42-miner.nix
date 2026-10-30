{
  config,
  inputs,
  lib,
  LT,
  pkgs,
  ...
}:
let
  scam-dn42-miner = pkgs.callPackage ../../pkgs/scam-dn42-miner {
    inherit (LT.sources.scam-dn42-miner) version src;
  };
in
{
  sops.secrets.scam-dn42-token = {
    sopsFile = inputs.secrets + "/scam-dn42.yaml";
    restartUnits = [ "scam-dn42-miner.service" ];
  };
  sops.templates.scam-dn42-miner-env.content = ''
    SCAM_DN42_TOKEN=${config.sops.placeholder.scam-dn42-token}
  '';

  systemd.services.scam-dn42-miner = {
    description = "Scummy Bank FPGA Miner";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      EnvironmentFile = config.sops.templates.scam-dn42-miner-env.path;
      ExecStart = "${lib.getExe scam-dn42-miner} --fpga --difficulty 8";

      PrivateDevices = false;

      # The miner handles SIGINT to cancel and acknowledge the active FPGA job.
      KillSignal = "SIGINT";
      Restart = "always";
      RestartSec = "5s";
    };
  };
  lantian.harden.scam-dn42-miner.enable = true;
}
