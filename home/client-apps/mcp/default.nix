{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  acorn = pkgs.fetchurl {
    url = "https://unpkg.com/acorn@8.14.0/dist/acorn.js";
    hash = "sha256-vsGUuauxAUfTu3flRNlc8ce0+fQtrQDfyDeRkJ6/Scc=";
  };

  claude-code = pkgs.claude-code.overrideAttrs (old: rec {
    version = "2.1.112";
    src = pkgs.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-SJJqU7XHbu9IRGPMJNUg6oaMZiQUKqJhI2wm7BnR1gs=";
    };

    # https://linux.do/t/topic/1991311
    postPatch = (old.postPatch or "") + ''
      install -Dm755 ${acorn} /tmp/acorn-claude-fix.js
      bash ${./apply-claude-code-subagent-thinking-fix.sh} cli.js
    '';
  });
in
{
  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.mcpServers or { };
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = claude-code;
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
      };
    };
  };
  xdg.configFile."opencode/opencode.json".force = true;

  programs.gemini-cli = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.gemini-cli;
  };

  programs.zed-editor = {
    enable = true;
    enableMcpIntegration = true;
  };

  home.activation = lib.mkIf (osConfig.lantian ? mcp) {
    setup-roo-code-mcp = ''
      ${pkgs.coreutils}/bin/install -Dm644 \
        "${osConfig.lantian.mcp.mcpJsonFile}" \
        "$HOME/.config/Code/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json"
    '';
  };
}
