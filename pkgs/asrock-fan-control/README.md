# asrock-fan-control

```sh
asrock-fan-control --config /path/fans.toml --read-once
asrock-fan-control --config /path/fans.toml
asrock-fan-control --failsafe --config /path/fans.toml
asrock-fan-control --failsafe
```

本程序仅支持 ASRock EPYCD8 已确认的八槽 `3a/01`、`3a/02` 命令，没有协议选择器，不自动探测或试写。`--device /dev/...` 指定配置错误时的恢复设备，默认 `/dev/ipmi0`；配置有效时须与 TOML 一致。

配置包含 `device`、`polling_seconds`、`fan_mode_delay_seconds`、`fan_slots`、`[motherboard]` 曲线及一个或多个 `[[gpus]]`。每张 GPU 必须提供完整 `gpu_uuid`、不同的零基 `fan_slot`，以及可选 `[gpus.curve]`。`fan_slots` 包含全部受控槽位；非 GPU 槽位使用所有可用非 GPU IPMI 温度的最大值。槽位映射及真实 UUID 由调用方验证，包中不提供虚构部署配置。

曲线参数直接复用 `smfc`：`min_speed`、`max_speed`、`min_temp`、`max_temp`、`sensitivity`、`steps`。默认 65–85°C 对应 30–75%，灵敏度 1°C、20 步。任一受监控温度达到 90°C，或任一 GPU 查询失败，恢复 100% 后退出。固定速度测试可将各曲线 `min_speed`、`max_speed` 同设为已批准的非零速度；程序不产生负载。

`--read-once` 输出 IPMI 温度、最大值、GPU 温度和硬件温度上限、目标及当前状态，任何路径均不写风扇、不发 systemd 通知。NVML 只从 `/run/opengl-driver/lib/libnvidia-ml.so.1` 加载，以 UUID 查询 NVIDIA GPU，不限制型号名称；仍要求 NVML 温度及阈值查询成功，硬件 slowdown 上限高于 90°C 且不高于 shutdown 上限。

程序读取 `3a/02` 的八字节状态，每字节必须在 0–100，0 表示自动。控制时保留未管理字节，只有载荷变化才写 `3a/01`，自动转手动后等待 `fan_mode_delay_seconds`，再检查完整读回。百分比与自动值参见 [ASRock FAQ](https://www.asrockrack.com/support/faq.asp)。测试夹具包含实际捕获的全自动、全 100% 和单槽 70% 读回；其他混合槽位和错误响应仍使用合成数据。

本包的 SDR 兼容层只将版本为零的非温度 event-only（类型 3）记录规范为 `0x51`，再交由原始共享解析器检查。温度记录、其他版本及其他类型仍保持原有严格校验；不修改 `smfc`。

`--failsafe` 不加载 NVML。有效配置且初始状态可读时保留未管理槽位；无配置或初始读失败则写全部八槽 100%。即使初始读失败也尝试写，写失败也继续尝试读回，不无限重试。

服务接入由调用方完成：`Type=notify`、watchdog，仅完整成功 tick 发送 `READY`/`WATCHDOG`。SIGTERM/SIGINT 或运行错误使用新 IPMI 描述符恢复。NVML 等待上限 8 秒，IPMI 请求超时 2 秒，模式等待最多 10 秒。watchdog 须覆盖实际 SDR 数量、采样和轮询间隔；SIGKILL 无法自行清理，服务须配置 `ExecStopPost=... --failsafe`。
