const fetch = require('node-fetch');
const nunjucks = require('nunjucks');

// https://github.com/wnwd/waline-notification-telegram-bot
module.exports = {
  hooks: {
    async postSave(comment, parent) {
      const {
        TELEGRAM_BOT_TOKEN,
        TELEGRAM_CHAT_ID,
        SITE_NAME,
        SITE_URL,
        TELEGRAM_TEMPLATE,
      } = process.env;

      if (!TELEGRAM_BOT_TOKEN || !TELEGRAM_CHAT_ID) {
        return false;
      }

      comment.comment = comment.comment.replace(/(<([^>]+)>)/gi, '');

      const data = {
        self: comment,
        parent,
        site: {
          name: SITE_NAME,
          url: SITE_URL,
          postUrl: SITE_URL + comment.url + '#' + comment.objectId,
        },
      };

      const template =
        TELEGRAM_TEMPLATE ||
        `{{site.name|safe}} 有新评论啦
【昵称】: {{self.nick}}
【邮箱】: {{self.mail}}
【内容】: {{self.comment}}
【地址】: {{site.postUrl}}`;

      const content = nunjucks.renderString(template, data);

      const msg = {
        chat_id: TELEGRAM_CHAT_ID,
        text: content,
        parse_mode: 'Markdown',
      };

      try {
        const resp = await fetch(
          `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(msg),
          },
        ).then((resp) => resp.json());

        if (!resp.ok) {
          console.log(
            'Telegram bot notification FAILED:',
            JSON.stringify(resp),
          );
        } else {
          console.log(
            'Telegram bot notification SUCCESS:',
            JSON.stringify(resp),
          );
        }
      } catch (error) {
        console.error('Send Telegram bot notification ERROR:', error);
      }
    },
  },
};
