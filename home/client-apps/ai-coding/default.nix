{
  pkgs,
  osConfig,
  LT,
  inputs,
  ...
}:
let
  context = builtins.concatStringsSep "\n" (
    builtins.map (f: "# ${builtins.baseNameOf f}\n" + builtins.readFile f) (LT.ls ./rules)
  );
in
{
  imports = [ (inputs.secrets + "/nixos-hidden-module/a7129082a691a699") ];

  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.codingMcpServers or { };
  };

  programs.pi-coding-agent = {
    enable = true;
    package = inputs.llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".pi.override {
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
      tokenrhythm = {
        api = "openai-completions";
        baseUrl = "https://tokenrhythm.studio/v1";
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
      defaultModel = "glm-5.3";
      defaultThinkingLevel = "high";
      showCacheMissNotices = true;

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
        "npm:@cortexkit/pi-magic-context"
        "npm:@moguw/pi-session-migrate"
        "npm:@monotykamary/pi-tps"
        "npm:@narumitw/pi-langfuse"
        "npm:@rwese/pi-question"
        "npm:pi-btw"
        "npm:pi-codex-goal"
        "npm:pi-fast-resume"
        "npm:pi-mcp-adapter"
        "npm:pi-model-discovery"
        "npm:pi-ollama-cloud"
        "npm:pi-simplify"
        "npm:pi-subagents"
        # keep-sorted end
      ];
    };
  };
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
  };
  # https://github.com/cortexkit/magic-context/blob/master/CONFIGURATION.md
  home.file.".config/cortexkit/magic-context.jsonc".text = builtins.toJSON {
    enabled = true;
    auto_update = false;
    allow_home_project = true;
    historian.pi.model = "ollama-cloud/glm-5.3";
    dreamer.pi.model = "ollama-cloud/glm-5.3";
    sidekick.model = "ollama-cloud/glm-5.3";
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
  home.file.".pi/agent/extensions/subagent/config.json".text = builtins.toJSON {
    toolDescriptionMode = "compact";
    parallel = {
      maxTasks = 100;
      concurrency = 100;
    };
    maxSubagentSpawnsPerSession = 10000;
  };
}
