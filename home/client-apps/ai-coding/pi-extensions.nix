{
  osConfig,
  ...
}:
let
  api_key =
    if builtins.hasAttr "pi-magic-context-openrouter-key" osConfig.sops.secrets then
      "{file:${osConfig.sops.secrets.pi-magic-context-openrouter-key.path}}"
    else
      "";
in
{
  home.file.".pi/agent/ollama-cloud.json".text = builtins.toJSON {
    webTools = false;
    usageStatus = true;
  };
  home.file.".pi/agent/ask-tool.json".text = builtins.toJSON {
    notify = true;
    timeoutSeconds = 300;
  };
  home.file.".pi/agent/pi-fff.json".text = builtins.toJSON {
    enableFsRootScanning = false;
    enableHomeDirScanning = false;
  };
  # Packages Pi Web skips while the pi CLI keeps them; see
  # patches/pi-web-disabled-packages.patch.
  home.file.".pi/agent/pi-web.json".text = builtins.toJSON {
    disabledPackages = [
      "npm:@monotykamary/pi-tps"
    ];
  };
  home.file.".pi/agent/pi-goal.json".text = builtins.toJSON {
    continuationLimits = {
      automaticTurns = null;
      noProgressTurns = null;
    };
    retryUsageLimits = true;
  };
  # https://github.com/cortexkit/magic-context/blob/master/CONFIGURATION.md
  home.file.".config/cortexkit/magic-context.jsonc".text = builtins.toJSON {
    enabled = true;
    auto_update = false;
    allow_home_project = true;
    historian.pi.model = "cliproxyapi/lantian/coding-fast";
    dreamer.pi.model = "cliproxyapi/lantian/coding-fast";
    sidekick.model = "cliproxyapi/lantian/coding-fast";
    embedding = {
      provider = "openai-compatible";
      model = "qwen/qwen3-embedding-8b";
      endpoint = "https://openrouter.ai/api/v1";
      inherit api_key;
      max_input_tokens = 32768;
    };
    rerank = {
      provider = "remote";
      endpoint = "https://openrouter.ai/api/v1";
      model = "qwen/qwen3-reranker-8b";
      inherit api_key;
      timeout_ms = 5000;
      top_n = 20;
    };
  };
  home.file.".pi/agent/extensions/pi-secret-mask/config.json".text = builtins.toJSON {
    mode = "auto";
    allowCommands = [ ];
    dotenv = {
      enabled = true;
      files = [
        ".env"
        ".env.local"
        ".env.production"
        ".env.development"
      ];
      exclude = [
        ".env.example"
        ".env.sample"
      ];
    };
    patterns = {
      openai = true;
      github = true;
      google = true;
      aws = true;
      jwt = true;
      pem = true;
      base64 = false;
    };
    extraSecrets = [ ];
    customPatterns = [ ];
  };
}
