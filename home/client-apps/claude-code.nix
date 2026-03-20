{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
  ];

  home.sessionVariables = {
    CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
    CLAUDE_CODE_BLOCKING_LIMIT_OVERRIDE = "193000";
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    CLAUDE_CODE_PROXY_RESOLVES_HOSTS = "1";
    DISABLE_INSTALLATION_CHECKS = "1";
    ENABLE_TOOL_SEARCH = "1";
  };
}