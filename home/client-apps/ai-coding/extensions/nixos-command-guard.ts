// Enforces ../rules/04-nixos.md: blocks non-Nix package managers,
// `make install`, `curl | sh` installers, and commands passing `/` or
// `/nix/store(/)` as a single argument. Multi-line commands (inline
// scripts) are skipped: a lone `/` inside a script is usually harmless.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const rules: Array<{ pattern: RegExp; reason: string }> = [
  {
    pattern: /\b(apt|apt-get|aptitude|yum|dnf|pacman|brew|snap|zypper)\b/,
    reason:
      "Non-Nix package managers are forbidden on this NixOS system. Use `nix` (e.g. `nix shell nixpkgs#<pkg>`) " +
      "or add the package to the Nix configuration instead.",
  },
  {
    pattern: /\bmake(\s+-[\w=.-]+)*\s+install\b/,
    reason:
      "Building from source with `make install` is forbidden on this NixOS system. Package the software with Nix instead.",
  },
  {
    pattern: /\b(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z|da)?sh\b/,
    reason:
      "Piping curl/wget into a shell to install software is forbidden on this NixOS system. Use Nix to install software instead.",
  },
  {
    // Bare `/` as a single argument (quoted or not), e.g. `find /`, `du -sh /`.
    pattern: /(?:^|\s)(?:"\/"|'\/'|\/)(?=\s|$)/,
    reason:
      "Passing `/` as a command argument is forbidden on this NixOS system: " +
      "searching from `/` traverses the entire filesystem (extremely slow), and destructive commands like `rm -rf /` are catastrophic. " +
      "Restrict the argument to a specific directory.",
  },
  {
    // `/nix/store` or `/nix/store/` as a single argument (quoted or not).
    pattern: /(?:^|\s)(?:"\/nix\/store\/?"|'\/nix\/store\/?'|\/nix\/store\/?)(?=\s|$)/,
    reason:
      "Passing `/nix/store` as a command argument is forbidden on this NixOS system: " +
      "it contains a huge number of files and traversing it is extremely slow, and destructive commands on it are catastrophic. " +
      "Restrict the argument to a specific path inside it, or use `which`, `whereis`, or `nix-locate` to locate system files.",
  },
];

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, _ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command = event.input.command as string;
    if (command.includes("\n")) return undefined;

    for (const rule of rules) {
      if (rule.pattern.test(command)) {
        return { block: true, reason: rule.reason };
      }
    }
    return undefined;
  });
}
