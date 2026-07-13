{
  pkgs,
  osConfig,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  context = builtins.concatStringsSep "\n" (
    builtins.map (f: "# ${builtins.baseNameOf f}\n" + builtins.readFile f) (LT.ls ./rules)
  );

  # https://github.com/openai/codex/issues/14599#issuecomment-4098754431
  codexWrapper = pkgs.writers.writePython3Bin "codex" { } ''
    import json
    import os
    import sys
    from pathlib import Path


    CODEX = "${lib.getExe config.programs.codex.package}"


    def main() -> None:
        project = json.dumps(str(Path.cwd()))
        config = f'projects={{{project}={{trust_level="trusted"}}}}'
        os.execvp(CODEX, [CODEX, "-c", config, *sys.argv[1:]])


    if __name__ == "__main__":
        main()
  '';
in
{
  home.packages = [ (lib.hiPrio codexWrapper) ];

  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.codingMcpServers or { };
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = inputs.llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".claude-code;
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
    package = inputs.llm-agents.packages."${pkgs.stdenv.hostPlatform.system}".opencode;
    settings = {
      autoupdate = false;
      provider = {
        generalcompute = {
          npm = "@ai-sdk/openai-compatible";
          name = "General Compute";
          options.baseURL = "https://api.generalcompute.com/v1";
          models."minimax-m2.7".name = "MiniMax M2.7";
        };
        linuxdo-hub = {
          npm = "@ai-sdk/openai-compatible";
          name = "Linux.DO Hub";
          options.baseURL = "https://hub.linux.do/v1";
          models."glm-5.2".name = "GLM 5.2";
        };
      };
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
            mcpServers = lib.mapAttrs (
              _: v: v // { alwaysAllow = [ "*" ]; }
            ) osConfig.lantian.mcp.codingMcpServers;
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
