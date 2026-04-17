{
  pkgs,
  lib,
  config,
  ...
}:
let
  claude-code = pkgs.runCommand "claude-code-wrapped" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe pkgs.llm-agents.claude-code} $out/bin/claude \
      --set-default ANTHROPIC_DEFAULT_HAIKU_MODEL "claude-haiku-4-5-20251001" \
      --set-default ANTHROPIC_DEFAULT_OPUS_MODEL "claude-opus-4-7[1m]" \
      --set-default ANTHROPIC_DEFAULT_SONNET_MODEL "claude-opus-4-7[1m]" \
      --set-default ANTHROPIC_MODEL "claude-opus-4-7[1m]" \
      --set-default ANTHROPIC_REASONING_MODEL "claude-opus-4-7[1m]" \
      --set-default CLAUDE_CODE_ATTRIBUTION_HEADER "0" \
      --set-default CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC "1" \
      --set-default CLAUDE_CODE_PROXY_RESOLVES_HOSTS "1" \
      --set-default CLAUDE_CONFIG_DIR "${config.xdg.configHome}/claude" \
      --set-default ENABLE_TOOL_SEARCH "1" \
      --add-flag "--dangerously-skip-permissions"
  '';
in
{
  home.packages = [ claude-code ];
}
