_: {
  # Pi loads extensions through jiti, which rewrites their `@earendil-works/*`
  # imports to pi's own copies. A prebuilt plain-JS bundle is loaded natively,
  # so its requires and dynamic imports get plain Node resolution and fail with
  # MODULE_NOT_FOUND, silently disabling whatever they were meant to do. Ship
  # the TypeScript sources and let pi's loader resolve them.
  home.file.".pi/agent/extensions/no-update-check.ts".source = ./extensions/no-update-check.ts;
  home.file.".pi/agent/extensions/nixos-command-guard.ts".source =
    ./extensions/nixos-command-guard.ts;
  home.file.".pi/agent/extensions/model-favorites.ts".source = ./extensions/model-favorites.ts;
  home.file.".pi/agent/extensions/deepseek-loop-guard.ts".source =
    ./extensions/deepseek-loop-guard.ts;
  home.file.".pi/agent/extensions/last-model.ts".source = ./extensions/last-model.ts;
  home.file.".pi/agent/extensions/sanitize-user-agent.ts".source =
    ./extensions/sanitize-user-agent.ts;
  home.file.".pi/agent/extensions/no-docs.ts".source = ./extensions/no-docs.ts;
}
