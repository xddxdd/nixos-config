# 子代理模型指定规则

每次调用子代理工具都必须显式传入 `model`，格式为 `provider/model`，不得省略。

默认取当前会话的 `PI_PROVIDER` 和 `PI_MODEL`，拼成 `PI_PROVIDER/PI_MODEL`，例如 `openai-codex-2/gpt-6-luna`。用户明确指定了其它模型时，改用用户给出的 `provider/model`。
