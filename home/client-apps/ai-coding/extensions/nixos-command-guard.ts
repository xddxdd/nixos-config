// Blocks commands passing `/` or `/nix/store(/)` as a single argument.
// Multi-line commands (inline
// scripts) are skipped: a lone `/` inside a script is usually harmless.

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const rules: Array<{ pattern: RegExp; reason: string }> = [
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
  pi.on("before_agent_start", (event) => {
    event.systemPromptOptions.sections.nixos_command_guard = `# NixOS 命令限制

## 禁止的操作

- **不要**使用 \`apt\`、\`apt-get\`、\`aptitude\`、\`yum\`、\`dnf\`、\`pacman\`、\`brew\`、\`snap\`、\`zypper\` 等非 Nix 包管理器
- **不要**从源码手动 \`make install\`（包括 \`sudo make install\`、\`make -jN install\` 等带参数的形式）
- **不要**使用 \`curl | sh\`、\`wget | sh\` 等管道到 shell 的方式安装软件

## 禁止从根目录搜索

- **不要**执行 \`find /\`、\`grep -r /\`、\`fd /\`、\`rg /\` 等搜索命令，即 \`find\`、\`fd\`、\`grep\`、\`rg\`、\`ag\`、\`ack\` 以根目录（\`/\`）或 \`/nix/store\` 为搜索路径的用法
- 在 NixOS 上，\`/nix/store\` 包含大量文件，从根目录或 \`/nix/store\` 遍历会极其缓慢，可能耗时数分钟甚至卡死
- 需要搜索时，应限定在具体目录内，例如 \`find /etc\`、\`rg . /home/user/project\`
- 如需查找系统文件，优先使用 \`which\`、\`whereis\`、\`nix-locate\` 等针对性工具`;
  });

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
