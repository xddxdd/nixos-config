{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.fish-speech = {
    extraOptions = [
      "--gpus=all"
      "--net=host"
    ];
    image = "docker.io/fishaudio/fish-speech:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
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

  systemd.tmpfiles.settings = {
    fish-speech = {
      "/var/lib/fish-speech/references"."d" = {
        mode = "755";
        user = "fish-speech";
        group = "fish-speech";
      };
    };
  };

  lantian.nginxVhosts."fish-speech.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.FishSpeech}";
        proxyNoTimeout = true;
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
