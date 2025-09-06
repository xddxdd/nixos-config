const GPTReviewer = require('waline-plugin-llm-reviewer');
const Telegram = require('waline-notification-telegram-bot');

const LLM_PROMPT = `
You are an expert in reviewing content. You are reviewing a comment made on a technical blog. Your task is to review the comments based on these criterias:

1. The comment should not look like spam.
2. The comment should not involve content that is not suitable for public display.
3. The comment should not include any political discussion.
4. The comment should not be hostile towards any entity.

Your output should be a single word:
- "spam": if the comment involves one of the undesirable categories specified above.
- "approved": if the comment does not include any of the undesired content.
- "waiting": if you cannot make a decision.

Under ANY circumstances, your output must be a single word "approved", "waiting" or "spam". If you are unsure, return "waiting".
`.trim();

process.stdout.write('Loading custom config...');

module.exports = {
  plugins: [
    GPTReviewer({
      openaiBaseUrl: 'https://openrouter.ai/api',
      openaiModel: 'deepseek/deepseek-r1-0528',
      openaiApiKey: process.env.OPENAI_API_KEY,
      openaiPrompt: LLM_PROMPT,
    }),
    Telegram,
  ],
};
