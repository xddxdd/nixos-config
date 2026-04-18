{
  pkgs,
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
  home.packages = [ claude-code ];
}
