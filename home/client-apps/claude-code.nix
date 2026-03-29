{ pkgs, config, ... }:
{
  home.packages = [ pkgs.llm-agents.claude-code ];

  home.sessionVariables = {
    CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
    CLAUDE_CODE_PROXY_RESOLVES_HOSTS = "1";
    ENABLE_TOOL_SEARCH = "1";
  };
}
