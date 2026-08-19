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
  home.packages = [ pkgs.rtk ];

  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.codingMcpServers or { };
  };

  programs.pi-coding-agent = {
    enable = true;
    package = inputs.llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".pi;
    # # Not implemented correctly in home manager
    # configDir = "${config.xdg.configHome}/pi/agent";
    inherit context;

    extraPackages = [
      pkgs.nodejs
      pkgs.bun
    ];

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
      defaultModel = "glm-5.2";
      defaultThinkingLevel = "high";
      showCacheMissNotices = true;

      packages = [
        # keep-sorted start
        "npm:@monotykamary/pi-tps"
        "npm:@narumitw/pi-langfuse"
        "npm:@rwese/pi-question"
        "npm:pi-btw"
        "npm:pi-codex-goal"
        "npm:pi-fast-resume"
        "npm:pi-mcp-adapter"
        "npm:pi-model-discovery"
        "npm:pi-ollama-cloud"
        "npm:pi-rtk-optimizer"
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
  home.file.".pi/agent/extensions/no-update-check.ts".source = ./extensions/no-update-check.ts;
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
