import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { getAgentDir } from '@earendil-works/pi-coding-agent';

type LastModel = { provider: string; id: string };

// settings.json is nix-managed, so the last-used model is persisted here instead.
function statePath(): string {
  return join(getAgentDir(), 'last-model.json');
}

function loadLastModel(): LastModel | undefined {
  if (!existsSync(statePath())) return undefined;
  try {
    const parsed = JSON.parse(readFileSync(statePath(), 'utf-8')) as Partial<LastModel>;
    if (typeof parsed.provider === 'string' && typeof parsed.id === 'string') {
      return { provider: parsed.provider, id: parsed.id };
    }
  } catch {
    // Corrupt state: fall back to the configured default.
  }
  return undefined;
}

function saveLastModel(model: LastModel): void {
  try {
    writeFileSync(statePath(), JSON.stringify(model, null, 2), 'utf-8');
  } catch {
    // Best-effort: a persistence failure must not break model switching.
  }
}

export default function lastModel(pi: ExtensionAPI): void {
  // Record explicit user choices (/model, Ctrl+P). "restore" (resumed session)
  // is skipped so an old session's model does not leak into new sessions.
  pi.on('model_select', async (event) => {
    if (event.source === 'set' || event.source === 'cycle') {
      saveLastModel({ provider: event.model.provider, id: event.model.id });
    }
  });

  pi.on('session_start', async (event, ctx) => {
    if (event.reason !== 'startup') return;
    // Resumed sessions restore their own recorded model; only fresh sessions
    // (no messages yet) get the last-used model applied over the settings default.
    if (ctx.sessionManager.getBranch().some((entry) => entry.type === 'message')) return;
    const last = loadLastModel();
    if (!last) return;
    const model = ctx.modelRegistry
      .getAvailable()
      .find((m) => m.provider === last.provider && m.id === last.id);
    if (!model) return;
    if (
      ctx.model &&
      ctx.model.provider === model.provider &&
      ctx.model.id === model.id
    ) {
      return;
    }
    try {
      await pi.setModel(model);
    } catch {
      // No auth configured for that provider: keep the settings default.
    }
  });
}
