{
  pkgs,
  LT,
  config,
  ...
}:
let
  openai-edge-tts = pkgs.nur-xddxdd.openai-edge-tts.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/openai-edge-tts-custom-listen-host.patch
    ];
  });
in
{
  systemd.services.openai-edge-tts = {
    description = "OpenAI Edge TTS";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      HOST = "127.0.0.1";
      PORT = LT.portStr.OpenAIEdgeTTS;
      REQUIRE_API_KEY = "False";
      DEFAULT_LANGUAGE = "zh-CN";
      DEFAULT_VOICE = "zh-CN-XiaoxiaoNeural";
      DEFAULT_RESPONSE_FORMAT = "mp3";
      DEFAULT_SPEED = "1.2";
    };

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${openai-edge-tts}/bin/openai-edge-tts";
      Restart = "always";
      RestartSec = "3";

      User = "openai-edge-tts";
      Group = "openai-edge-tts";
    };
  };

  users.users.openai-edge-tts = {
    group = "openai-edge-tts";
    isSystemUser = true;
  };
  users.groups.openai-edge-tts = { };

  lantian.nginxVhosts."openai-edge-tts.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenAIEdgeTTS}";
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
