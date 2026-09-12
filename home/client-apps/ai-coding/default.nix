{
  pkgs,
  osConfig,
  LT,
  lib,
  config,
  inputs,
  ...
}:
let
  context = builtins.concatStringsSep "\n" (
    builtins.map (f: "# ${builtins.baseNameOf f}\n" + builtins.readFile f) (LT.ls ./rules)
  );
in
{
  imports = [
    (inputs.secrets + "/nixos-hidden-module/09e0a4212f82100c")
    (inputs.secrets + "/nixos-hidden-module/a7129082a691a699")
  ];

  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.codingMcpServers or { };
  };

  programs.pi-coding-agent = {
    enable = true;
    package = pkgs.llm-agents.pi.override {
      useBun = false;
    };
    # # Not implemented correctly in home manager
    # configDir = "${config.xdg.configHome}/pi/agent";
    inherit context;

    extraPackages = [ pkgs.nodejs ];

    models.providers = {
      linuxdo-hub = {
        api = "openai-completions";
        baseUrl = "https://hub.linux.do/v1";
      };
      uni-api = {
        api = "openai-completions";
        baseUrl = "https://ai-api.xuyh0120.win/v1";
      };
    };

    settings = {
      quietStartup = true;
      collapseChangelog = true;
      enableInstallTelemetry = false;
      enableAnalytics = false;
      defaultProvider = "ollama-cloud";
      defaultModel = "glm-5.3-flash";
      defaultThinkingLevel = "high";
      showCacheMissNotices = false;

      retry = {
        enabled = true;
        maxRetries = 3;
        baseDelayMs = 2000;
        provider = {
          timeoutMs = 3600 * 1000;
          maxRetries = 3;
          maxRetryDelayMs = 60 * 1000;
        };
      };

      packages = [
        # keep-sorted start
        "git:github.com/xddxdd/pi-model-discovery@v0.3.1"
        "npm:@cortexkit/pi-magic-context"
        "npm:@moguw/pi-session-migrate"
        "npm:@monotykamary/pi-tps"
        "npm:@narumitw/pi-langfuse"
        "npm:@rwese/pi-question"
        "npm:pi-btw"
        "npm:pi-codex-goal"
        "npm:pi-fast-resume"
        "npm:pi-mcp-adapter"
        "npm:pi-ollama-cloud"
        "npm:pi-secret-mask"
        "npm:pi-simplify"
        "npm:pi-subagents"
        # keep-sorted end
      ];
    };
  };
  # Pi loads TS extensions through jiti, whose transpile cache lives in
  # $TMPDIR/jiti. /tmp is tmpfs here, so the cache is wiped on every reboot
  # and the first pi launch after boot recompiles ~400 modules (~14 s).
  # Symlink the cache to a persistent location; verified:
  # cold 14.4 s -> warm 1.8 s, and with the symlink warm stays 1.8 s.
  home.activation.link-jiti-cache = lib.optionalString (config.home.username == "lantian") ''
    mkdir -p "$HOME/.cache/jiti"
    # jiti may have created a real directory before this link existed
    if [ -d /tmp/jiti ] && [ ! -L /tmp/jiti ]; then
      rm -rf /tmp/jiti
    fi
    ln -sfn "$HOME/.cache/jiti" /tmp/jiti
  '';

  home.file.".pi/agent/mcp.json".text = builtins.toJSON {
    settings = {
      directTools = true;
      disableProxyTool = true;
      # Disabled for extra logging to TUI
      freezeDirectTools = false;
      idleTimeout = 5;
      mcpFooterStatus = "off";
      requestTimeoutMs = 60000;
      scriptMode = false;
    };
  };
  home.file.".pi/agent/ollama-cloud.json".text = builtins.toJSON {
    webTools = false;
    usageStatus = true;
  };
  # https://github.com/cortexkit/magic-context/blob/master/CONFIGURATION.md
  home.file.".config/cortexkit/magic-context.jsonc".text = builtins.toJSON {
    enabled = true;
    auto_update = false;
    allow_home_project = true;
    historian.pi.model = "ollama-cloud/glm-5.3-flash";
    dreamer.pi.model = "ollama-cloud/glm-5.3-flash";
    sidekick.model = "ollama-cloud/glm-5.3-flash";
    embedding = {
      provider = "openai-compatible";
      model = "nomic-embed-code";
      endpoint = "http://127.0.0.1:${LT.portStr.LlamaSwap}/v1";
    };
  };
  home.file.".pi/agent/extensions/no-update-check.ts".source = ./extensions/no-update-check.ts;
  home.file.".pi/agent/extensions/nixos-command-guard.ts".source =
    ./extensions/nixos-command-guard.ts;
  home.file.".pi/agent/extensions/model-favorites.ts".source = ./extensions/model-favorites.ts;
  home.file.".pi/agent/extensions/last-model.ts".source = ./extensions/last-model.ts;
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
  home.file.".pi/agent/extensions/subagent/config.json".text = builtins.toJSON {
    toolDescriptionMode = "compact";
    parallel = {
      maxTasks = 100;
      concurrency = 100;
    };
    maxSubagentSpawnsPerSession = 10000;
  };
}
