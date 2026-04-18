{
  pkgs,
  lib,
  config,
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

  claude-code-wrapped =
    pkgs.runCommand "claude-code-wrapped" { nativeBuildInputs = [ pkgs.makeWrapper ]; }
      ''
        mkdir -p $out/bin
        makeWrapper ${lib.getExe claude-code} $out/bin/claude \
          --set-default ANTHROPIC_BETAS "context-1m-2025-08-07" \
          --set-default ANTHROPIC_DEFAULT_HAIKU_MODEL "claude-haiku-4-5-20251001" \
          --set-default ANTHROPIC_DEFAULT_OPUS_MODEL "claude-opus-4-7[1m]" \
          --set-default ANTHROPIC_DEFAULT_SONNET_MODEL "claude-opus-4-7[1m]" \
          --set-default ANTHROPIC_MODEL "claude-opus-4-7[1m]" \
          --set-default ANTHROPIC_REASONING_MODEL "claude-opus-4-7[1m]" \
          --set-default CLAUDE_CODE_ATTRIBUTION_HEADER "0" \
          --set-default CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC "1" \
          --set-default CLAUDE_CODE_PROXY_RESOLVES_HOSTS "1" \
          --set-default CLAUDE_CONFIG_DIR "${config.xdg.configHome}/claude" \
          --set-default DISABLE_TELEMETRY "1" \
          --set-default ENABLE_TOOL_SEARCH "1" \
          --add-flag "--dangerously-skip-permissions"
      '';
in
{
  home.packages = [ claude-code-wrapped ];
}
