# 子代理模型指定规则

## 核心要求

每次调用子代理工具时，都必须显式传入 `model`，格式为 `provider/model`。

默认使用当前 Pi 会话指定的 provider 和模型 ID。通过检查当前会话环境变量 `PI_PROVIDER` 和 `PI_MODEL` 获取这两个值，并按 `PI_PROVIDER/PI_MODEL` 拼成传给子代理的 `model`，例如 `openai-codex-2/gpt-6-luna`。如果用户明确指定了其他模型，则使用用户指定的 `provider/model`。无论使用默认模型还是用户指定的模型，都不得省略 `model` 参数。
