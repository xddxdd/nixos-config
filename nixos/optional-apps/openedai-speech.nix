{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.openedai-speech = {
    extraOptions = [
      "--pull=always"
      "--gpus=all"
    ];
    image = "ghcr.io/matatonic/openedai-speech:dev";
    ports = [ "127.0.0.1:${LT.portStr.OpenedAISpeech}:8000" ];
    volumes = [
      "/var/lib/openedai-speech/voices:/app/voices"
      "/var/lib/openedai-speech/config:/app/config"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/openedai-speech/voices 755 root root"
    "d /var/lib/openedai-speech/config 755 root root"
  ];

  lantian.nginxVhosts."openedai-speech.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenedAISpeech}";
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
