{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.fish-speech = {
    extraOptions = [
      "--pull=always"
      "--gpus=all"
      "--net=host"
    ];
    image = "fishaudio/fish-speech:latest";
    cmd = [
      "python"
      "tools/api_server.py"
      "--listen"
      "127.0.0.1:${LT.portStr.FishSpeech}"
    ];
    volumes = [
      "/var/lib/fish-speech/references:/opt/fish-speech/references"
    ];
  };

  users.users.fish-speech = {
    group = "fish-speech";
    isSystemUser = true;
    home = "/var/cache/fish-speech";
    createHome = false;
  };
  users.groups.fish-speech = { };

  systemd.tmpfiles.rules = [ "d /var/lib/fish-speech/references 755 fish-speech fish-speech" ];

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
