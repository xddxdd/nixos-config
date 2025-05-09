const GPTReviewer = require('waline-plugin-llm-reviewer');
const Telegram = require('waline-notification-telegram-bot');

const LLM_PROMPT = `
You are an expert in reviewing content. You are reviewing a comment made on a technical blog. Your task is to review the comments based on these criterias:

1. The comment should not look like spam.
2. The comment should not involve content that is not suitable for public display.
3. The comment should not include any political discussion.
4. The comment should not be hostile towards any entity.

Under any circumstances, your output must be a single word (approved/spam). If you are unsure, choose one that is most likely.
`.trim();

process.stdout.write('Loading custom config...');

module.exports = {
  plugins: [
    GPTReviewer({
      openaiBaseUrl: process.env.OPENAI_BASE_URL,
      openaiModel: process.env.OPENAI_MODEL,
      openaiApiKey: process.env.OPENAI_API_KEY,
      openaiPrompt: LLM_PROMPT,
    }),
    Telegram,
  ],
};
