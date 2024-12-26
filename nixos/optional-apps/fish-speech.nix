{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
{
  systemd.services.fish-speech = {
    description = "Fish Speech API server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.ffmpeg ];

    preStart =
      let
        model = "fish-speech-${lib.versions.pad 2 pkgs.nur-xddxdd.fish-speech.version}";
      in
      ''
        ${pkgs.python3Packages.huggingface-hub}/bin/huggingface-cli download --resume-download fishaudio/${model} --local-dir checkpoints/${model}
        rm -f references
        mkdir -p /var/lib/fish-speech/references
        ln -sf /var/lib/fish-speech/references ./references
      '';

    serviceConfig = LT.serviceHarden // {
      ExecStart =
        let
          inherit (inputs.nur-xddxdd.legacyPackagesWithCuda.${pkgs.system}) fish-speech;
        in
        "${fish-speech}/bin/fish-speech-api --listen 127.0.0.1:${LT.portStr.FishSpeech}";
      Restart = "always";
      RestartSec = "3";

      User = "fish-speech";
      Group = "fish-speech";

      CacheDirectory = "fish-speech";
      StateDirectory = "fish-speech";
      WorkingDirectory = "/var/cache/fish-speech";
      TimeoutStopSec = "5";

      # for GPU acceleration
      MemoryDenyWriteExecute = lib.mkForce false;
      PrivateDevices = false;
      ProcSubset = "all";
    };
  };

  users.users.fish-speech = {
    group = "fish-speech";
    isSystemUser = true;
    home = "/var/cache/fish-speech";
    createHome = false;
  };
  users.groups.fish-speech = { };

  lantian.nginxVhosts."fish-speech.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.FishSpeech}";
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
