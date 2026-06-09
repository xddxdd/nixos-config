{
  pkgs,
  osConfig,
  lib,
  LT,
  ...
}:
let
  context = builtins.concatStringsSep "\n" (
    builtins.map (f: "# ${builtins.baseNameOf f}\n" + builtins.readFile f) (LT.ls ./rules)
  );
in
{
  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.mcpServers or { };
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.claude-code;
    inherit context;
  };

  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    inherit context;

    settings = {
      analytics.enabled = false;
      check_for_update_on_startup = false;
      default_permissions = ":workspace";

      model = "gpt-5.5";
      model_provider = "anyrouter";
      model_reasoning_effort = "xhigh";
      preferred_auth_method = "apikey";
      model_providers.anyrouter = {
        name = "AnyRouter";
        base_url = "https://anyrouter.top/v1";
        wire_api = "responses";
        request_max_retries = 99;
        stream_max_retries = 99;
      };
    };
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.opencode;
    settings = {
      autoupdate = false;
      permission = {
        bash = "allow";
        edit = "allow";
        write = "allow";
        read = "allow";
        grep = "allow";
        glob = "allow";
        lsp = "allow";
        apply_patch = "allow";
        skill = "allow";
        todowrite = "allow";
        webfetch = "allow";
        websearch = "allow";
        question = "allow";
        external_directory = {
          "/nix/store/**" = "allow";
          "~/Projects/**" = "allow";
          "/tmp/**" = "allow";
        };
      };
    };
    inherit context;
  };
  xdg.configFile."opencode/opencode.json".force = true;

  programs.zed-editor = {
    enable = true;
    enableMcpIntegration = true;
  };

  home.activation = lib.mkIf (osConfig.lantian ? mcp) {
    setup-zoo-code-mcp =
      let
        mcpJsonFile = pkgs.writeText "mcp.json" (
          builtins.toJSON {
            mcpServers = lib.mapAttrs (_: v: v // { alwaysAllow = [ "*" ]; }) osConfig.lantian.mcp.mcpServers;
          }
        );
      in
      ''
        ${pkgs.coreutils}/bin/install -Dm644 \
          "${mcpJsonFile}" \
          "$HOME/.config/Code/User/globalStorage/zoocodeorganization.zoo-code/settings/mcp_settings.json"
      '';
  };

  home.file.".roo/rules".source = ./rules;
}
