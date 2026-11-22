import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

// No setting drops only the <docs> section, and SYSTEM.md would replace the whole
// default prompt (tools, rules, cwd). Strip the section after the prompt is built.
export default function (pi: ExtensionAPI) {
  pi.on('before_agent_start', (event) => ({
    systemPrompt: event.systemPrompt.replace(/\n*<docs>[\s\S]*?<\/docs>/g, ''),
  }));
}
