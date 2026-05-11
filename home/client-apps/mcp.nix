{
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.mcpServers or { };
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    package = pkgs.llm-agents.claude-code;
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
          "/nix/store" = "allow";
          "~/Projects" = "allow";
        };
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
