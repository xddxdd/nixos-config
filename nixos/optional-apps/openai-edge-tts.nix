{ LT, config, ... }:
{
  virtualisation.oci-containers.containers.openai-edge-tts = {
    extraOptions = [ "--pull=always" ];
    image = "travisvn/openai-edge-tts";
    ports = [ "127.0.0.1:${LT.portStr.OpenAIEdgeTTS}:5050" ];
    environment = {
      REQUIRE_API_KEY = "False";
      DEFAULT_LANGUAGE = "zh-CN";
      DEFAULT_VOICE = "zh-CN-XiaoxiaoNeural";
      DEFAULT_RESPONSE_FORMAT = "mp3";
      DEFAULT_SPEED = "1.2";
    };
  };

  lantian.nginxVhosts."openai-edge-tts.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenAIEdgeTTS}";
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
