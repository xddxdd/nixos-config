module.exports = function ({
  openaiBaseUrl,
  openaiModel,
  openaiApiKey,
  openaiPrompt,
}) {
  if (!openaiBaseUrl || !openaiModel || !openaiApiKey) {
    return {};
  }

  if (!openaiPrompt) {
    openaiPrompt =
      'You are a review bot. Your task is to review the comments according to following rules: \
      1. Any contact information should not be included, including qq number, email, phone number, etc. \
      2. Any content with advertising or sensitive information should not be included. \
      3. Any other content that is not suitable for public display should not be included. \
      4. Output should be a single word(approved/spam). \
      ';
  }

  const doReview = async (comment) => {
    const payload = `<nickname>${comment.nick}</nickname>
<email>${comment.mail}</email>
<content>${comment.comment}</content>`;

    const response = await fetch(openaiBaseUrl + '/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openaiApiKey}`,
      },
      body: JSON.stringify({
        model: openaiModel,
        messages: [
          {
            role: 'system',
            content: openaiPrompt,
          },
          {
            role: 'user',
            content: payload,
          },
        ],
        reasoning: {
          enabled: true,
        },
      }),
    });
    const data = await response.json();
    if (data && data.choices && data.choices.length > 0) {
      console.log('llm response', data.choices[0].message);
      return data.choices[0].message.content;
    } else {
      return 'waiting';
    }
  };

  return {
    hooks: {
      async preSave(data) {
        const { userInfo } = this.ctx.state;
        const isAdmin = userInfo.type === 'administrator';
        // ignore admin comment
        if (isAdmin) {
          return;
        }

        try {
          const resp = await doReview(data);

          if (resp === 'approved' || resp === 'spam' || resp === 'waiting') {
            data.status = resp;
          } else {
            data.status = 'waiting';
          }
        } catch (e) {
          console.log(e);
          data.status = 'waiting';
        }
      },
    },
  };
};
