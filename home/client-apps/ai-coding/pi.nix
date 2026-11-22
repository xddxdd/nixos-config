{
  pkgs,
  osConfig,
  LT,
  lib,
  config,
  ...
}:
let
  context = builtins.concatStringsSep "\n" (
    builtins.map (f: "# ${builtins.baseNameOf f}\n" + builtins.readFile f) (LT.ls ./rules)
  );

  # The models come straight from pve-epyc's own llama-swap configuration
  # (nixos/optional-apps/llama-swap), which already leaves out what that host
  # cannot run; only the chat models are of use to a chat client.
  llamaSwapModels = lib.filterAttrs (
    _: m: m.mode == "chat"
  ) LT.nixosConfigurations."pve-epyc".config.lantian.llama-swap.models;
in
{
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
      defaultProvider = "cliproxyapi";
      defaultModel = "lantian/coding-fast";
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
        "npm:@narumitw/pi-goal"
        "npm:@router-for-me/pi-cliproxyapi-provider"
        "npm:pi-btw"
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
  home.file.".pi/agent/models.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/models.schema.json";
    providers.llama-swap = {
      name = "llama-swap (pve-epyc)";
      baseUrl = "https://llama-swap.pve-epyc.xuyh0120.win/v1";
      api = "openai-completions";
      apiKey = "llama-swap";
      models = lib.mapAttrsToList (
        id: m:
        {
          inherit id;
          inherit (m) name maxTokens;
          contextWindow = m.ctxSize;
        }
        // lib.optionalAttrs m.thinking { reasoning = true; }
        // lib.optionalAttrs m.vision {
          input = [
            "text"
            "image"
          ];
        }
      ) llamaSwapModels;
    };
  };
}
