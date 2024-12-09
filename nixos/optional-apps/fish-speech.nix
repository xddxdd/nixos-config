{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.fish-speech = {
    extraOptions = [
      "--pull=always"
      "--gpus=all"
      "--net=host"
    ];
    image = "lengyue233/fish-speech:v1.4.3";
    cmd = [
      "python"
      "tools/api.py"
      "--listen"
      "127.0.0.1:${LT.portStr.FishSpeech}"
    ];
  };

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
