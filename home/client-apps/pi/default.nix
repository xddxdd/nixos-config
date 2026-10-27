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

  api_key =
    if builtins.hasAttr "pi-magic-context-openrouter-key" osConfig.sops.secrets then
      "{file:${osConfig.sops.secrets.pi-magic-context-openrouter-key.path}}"
    else
      "";
in
{
  imports = [
    (inputs.secrets + "/nixos-hidden-module/09e0a4212f82100c")
    (inputs.secrets + "/nixos-hidden-module/a7129082a691a699")
  ];

  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.mcpServers or { };
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

    settings = {
      # grep/find built-ins are disabled here; the pi-fff package below replaces
      # them with ffgrep/fffind/fff-multi-grep. codemode and tool_search are
      # built-in extensions, off by default.
      defaultTools = [
        "+ls"
        "+codemode"
        "+tool_search"
      ];
      quietStartup = true;
      tuiMode = "regular";
      collapseChangelog = true;
      enableInstallTelemetry = false;
      enableAnalytics = false;
      defaultProvider = "ollama-cloud";
      defaultModel = "glm-5.3-flash";
      defaultThinkingLevel = "high";
      showCacheMissNotices = false;

      steeringMode = "all";
      followUpMode = "all";
      doubleEscapeAction = "tree";
      treeFilterMode = "user-only";

      compaction.enabled = false; # Handled by magic context plugin

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
        "npm:@ff-labs/pi-fff"
        "npm:@gamaraan/ask-tool"
        "npm:@mjakl/pi-subagent"
        "npm:@moguw/pi-session-migrate"
        "npm:@monotykamary/pi-tps"
        "npm:@router-for-me/pi-cliproxyapi-provider"
        "npm:pi-btw"
        "npm:pi-codex-goal"
        "npm:pi-copy-message"
        "npm:pi-fast-resume"
        "npm:pi-ollama-cloud"
        "npm:pi-secret-mask"
        "npm:pi-simplify"
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
    mcpServers = lib.mapAttrs (_: server: server // { exposure = "direct"; }) (
      osConfig.lantian.mcp.mcpServers or { }
    );
  };
  home.file.".pi/agent/ollama-cloud.json".text = builtins.toJSON {
    webTools = false;
    usageStatus = true;
  };
  # Strata inference server on pve-epyc (nixos/optional-apps/strata.nix),
  # exposed through the private vhost. The server takes any API key and any
  # model name; the id below matches what the deployed quant reports via
  # /v1/models (n_ctx 204800, text+image input).
  home.file.".pi/agent/models.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/models.schema.json";
    providers.strata = {
      name = "Strata (pve-epyc)";
      baseUrl = "https://strata.pve-epyc.xuyh0120.win/v1";
      api = "openai-completions";
      apiKey = "strata";
      models = [
        {
          id = "qwen3.8-flash-next-iq3_s";
          name = "Qwen 3.8 Flash Next (pve-epyc)";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 204800;
          maxTokens = 8192;
        }
      ];
    };
  };
  home.file.".pi/agent/ask-tool.json".text = builtins.toJSON {
    notify = true;
    timeoutSeconds = 300;
  };
  home.file.".pi/agent/pi-fff.json".text = builtins.toJSON {
    enableFsRootScanning = false;
    enableHomeDirScanning = false;
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
  home.file.".pi/agent/extensions/no-update-check.ts".source = ./extensions/no-update-check.ts;
  home.file.".pi/agent/extensions/nixos-command-guard.ts".source =
    ./extensions/nixos-command-guard.ts;
  home.file.".pi/agent/extensions/model-favorites.ts".source = ./extensions/model-favorites.ts;
  home.file.".pi/agent/extensions/last-model.ts".source = ./extensions/last-model.ts;
  home.file.".pi/agent/extensions/sanitize-user-agent.ts".source =
    ./extensions/sanitize-user-agent.ts;
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
