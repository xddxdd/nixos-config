import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

// DeepSeek reasoning occasionally settles into a loop, repeating the same lead-in
// ("Let me ...") until it runs out of output tokens. Watch the streamed thinking,
// abort the run when the repetition becomes dense, then re-issue the prompt.
//
// ctx.abort() marks the run as user-aborted, so Pi never auto-retries it: the retry
// is issued from agent_settled, where Pi defers work until the run has settled.
// Retries are capped per run and the counter resets on a normal end.

const WINDOW = 2000; // trailing thinking characters inspected for repetition
const CHECK_EVERY = 200; // characters appended between checks
const LEAD_IN = /(?:^|\n)[^\S\n]*let me\b/g; // paragraphs opening with "Let me"
const LEAD_IN_LIMIT = 50;
const MAX_RETRIES = 2;
const RETRY_HINT =
  'Do not overthink: act on the evidence you already have instead of restating the same plan again.';

function looping(text: string): boolean {
  return (text.toLowerCase().match(LEAD_IN)?.length ?? 0) >= LEAD_IN_LIMIT;
}

export default function deepseekLoopGuard(pi: ExtensionAPI): void {
  let window = '';
  let pending = 0;
  let loopFound = false;
  let retries = 0;
  let prompt: string | undefined;

  pi.on('before_agent_start', (event) => {
    if (event.messageType === 'user' && event.prompt) prompt = event.prompt;
  });

  pi.on('message_start', (event) => {
    if (event.message.role !== 'assistant') return;
    window = '';
    pending = 0;
    loopFound = false;
  });

  pi.on('message_update', (event, ctx) => {
    const delta = event.assistantMessageEvent;
    if (delta.type !== 'thinking_delta' || loopFound) return;
    window = (window + delta.delta).slice(-WINDOW);
    pending += delta.delta.length;
    if (pending < CHECK_EVERY) return;
    pending = 0;
    if (!looping(window)) return;
    loopFound = true;
    ctx.abort();
  });

  pi.on('agent_settled', (event, ctx) => {
    if (!event.aborted) {
      retries = 0;
      return;
    }
    if (!loopFound) return;
    loopFound = false;
    if (retries >= MAX_RETRIES || !prompt) {
      ctx.ui.notify(`Repeated thinking loop: no more retries after ${retries}`, 'warning');
      return;
    }
    retries++;
    ctx.ui.notify(`Repeated thinking loop: retry ${retries}/${MAX_RETRIES}`, 'info');
    // display: false keeps the retried prompt out of the transcript; it still
    // reaches the model as a user message. The hint rides along with the prompt
    // so the model does not restart the same reasoning loop.
    pi.sendMessage(
      {
        customType: 'deepseek-loop-guard-retry',
        content: `${prompt}\n\n${RETRY_HINT}`,
        display: false,
      },
      { triggerTurn: true },
    );
  });
}
