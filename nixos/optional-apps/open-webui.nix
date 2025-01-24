{
  LT,
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./fish-speech.nix
    ./openai-edge-tts.nix
    ./openedai-speech.nix
    ./tika.nix
    ./uni-api
  ];

  age.secrets.open-webui-env.file = inputs.secrets + "/open-webui-env.age";

  services.open-webui = {
    enable = true;
    package = inputs.nixpkgs-stable.legacyPackages."${pkgs.system}".open-webui;
    port = LT.port.OpenWebUI;
    environmentFile = config.age.secrets.open-webui-env.path;
    environment = {
      ENV = "prod";

      GLOBAL_LOG_LEVEL = "WARNING";
      AUDIO_LOG_LEVELL = "WARNING";
      COMFYUI_LOG_LEVELL = "WARNING";
      CONFIG_LOG_LEVELL = "WARNING";
      DB_LOG_LEVELL = "WARNING";
      IMAGES_LOG_LEVELL = "WARNING";
      LITELLM_LOG_LEVELL = "WARNING";
      MAIN_LOG_LEVELL = "WARNING";
      MODELS_LOG_LEVELL = "WARNING";
      OLLAMA_LOG_LEVELL = "WARNING";
      OPENAI_LOG_LEVELL = "WARNING";
      RAG_LOG_LEVELL = "WARNING";
      WEBHOOK_LOG_LEVELL = "WARNING";

      OLLAMA_API_BASE_URL = "https://ollama.lt-home-vm.xuyh0120.win";
      WEBUI_URL = "https://ai.xuyh0120.win";
      OPENAI_API_BASE_URL = "http://uni-api.localhost/v1";

      ENABLE_LOGIN_FORM = "False";
      ENABLE_SIGNUP = "False";
      ENABLE_OAUTH_SIGNUP = "True";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
      OAUTH_CLIENT_ID = "open-webui";
      OAUTH_SCOPES = "openid profile email groups";
      ENABLE_OAUTH_ROLE_MANAGEMENT = "True";
      OAUTH_ROLES_CLAIM = "groups";
      OPENID_PROVIDER_URL = "https://login.lantian.pub/.well-known/openid-configuration";

      RAG_EMBEDDING_ENGINE = "ollama";
      PDF_EXTRACT_IMAGES = "false";
      RAG_EMBEDDING_MODEL = "jeffh/intfloat-multilingual-e5-large:f16";
      RAG_EMBEDDING_OPENAI_BATCH_SIZE = "512";
      RAG_TOP_K = "10";
      CHUNK_SIZE = "512"; # multilingual-e5-large supports 512 max
      CHUNK_OVERLAP = "180";
      CONTENT_EXTRACTION_ENGINE = "tika";
      TIKA_SERVER_URL = "http://127.0.0.1:${LT.portStr.Tika}";

      ENABLE_IMAGE_GENERATION = "true";
      IMAGE_GENERATION_ENGINE = "automatic1111";
      AUTOMATIC1111_BASE_URL = "https://stable-diffusion.xuyh0120.win";
      IMAGE_SIZE = "512x512";
      IMAGE_STEPS = "20";

      ENABLE_RAG_WEB_SEARCH = "true";
      ENABLE_SEARCH_QUERY = "true";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "https://searx.xuyh0120.win/search?q=<query>";
      RAG_WEB_SEARCH_RESULT_COUNT = "5";
      RAG_WEB_SEARCH_CONCURRENT_REQUESTS = "1";

      AUDIO_TTS_ENGINE = "openai";
      AUDIO_TTS_API_KEY = "unused";
      AUDIO_TTS_OPENAI_API_BASE_URL = "http://127.0.0.1:${LT.portStr.OpenAIEdgeTTS}";
      AUDIO_TTS_OPENAI_API_KEY = "unused";
      AUDIO_TTS_MODEL = "tts-1";
      AUDIO_TTS_VOICE = "zh-CN-XiaoxiaoNeural";
      AUDIO_TTS_SPLIT_ON = "punctuation";
    };
  };

  systemd.services.open-webui.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "open-webui";
    Group = "open-webui";
  };
  users.users.open-webui = {
    group = "open-webui";
    isSystemUser = true;
  };
  users.groups.open-webui = { };

  lantian.nginxVhosts = {
    "ai.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenWebUI}";
        proxyWebsockets = true;
        proxyNoTimeout = true;
      };

      sslCertificate = "xuyh0120.win_ecc";
      noIndex.enable = true;
    };
  };
}
