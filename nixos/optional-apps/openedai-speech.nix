{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  systemd.services.openedai-speech = {
    description = "OpenedAI Speech";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStartPre = "-${pkgs.nur-xddxdd.openedai-speech}/bin/download_voices_tts-1.sh";
      ExecStart = "${pkgs.nur-xddxdd.openedai-speech}/bin/openedai-speech --host 127.0.0.1 --port ${LT.portStr.OpenedAISpeech}";
      Restart = "always";
      RestartSec = "3";

      MemoryDenyWriteExecute = lib.mkForce false;
      PrivateDevices = lib.mkForce false;
      ProcSubset = "all";

      StateDirectory = "openedai-speech";
      WorkingDirectory = "/var/lib/openedai-speech";

      User = "openedai-speech";
      Group = "openedai-speech";
    };
  };

  users.users.openedai-speech = {
    group = "openedai-speech";
    isSystemUser = true;
  };
  users.groups.openedai-speech = { };

  lantian.nginxVhosts."openedai-speech.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenedAISpeech}";
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
