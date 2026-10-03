# fastpit 项目指南

## 维护规则

新增或修改任何功能时（新的 CLI 参数、新的路由行为、新的生成规则、缓存或种子设计的改动），必须同步更新本文档对应章节，不要留到后续提交再补。

## 概述

fastpit 是一个 LLM tarpit：对外提供一个「看起来像真的」的博客站点，任意路径都能渲染出页面，页面内容由 `data/corpus.bin` 语料确定性生成，页面模板来自 `assets/` 下的 HTML 文件、静态资源同样在运行时从该目录读取。语料只支持 `corpus.bin`（Cap'n Proto）这一种格式，页面模板不在语料里。它不写任何文件，适合在大量并发连接下低成本地拖住爬虫与抓取器。

三条硬性原则：

1. **确定性**：同一路径在刷新和重启后字节完全一致，RNG 由 `(global_seed, path)` 派生。
2. **无限页面**：不落盘，任意路径按需渲染。
3. **并发性能**：tokio 多线程 + axum，共享 `Arc` 状态，有界分片缓存。

## 目录结构

```
Cargo.toml          Rust 包清单与依赖
Cargo.lock          锁文件（default.nix 的 cargoLock.lockFile 依赖它）
build.rs            用 capnpc 编译 data/corpus.capnp，产物落 $OUT_DIR/corpus_capnp.rs
default.nix         rustPlatform.buildRustPackage（src = ./.）；postInstall 把资产装到 $out/share/fastpit/assets
README.md           使用说明（数据管线与格式见 data/README.md）
AGENTS.md           本文件
SPEC.md             实现规约（绑定文档）
src/
  main.rs           CLI 解析、资产目录与语料加载、tokio 运行时构建、绑定与启动
  app.rs            App 状态、路由、响应缓存、请求处理
  corpus.rs         Cap'n Proto 语料加载（加载时复制索引、词串零拷贝）、两遍式句子生成
  mmap.rs           corpus.bin 的 memmap2 映射
  rng.rs            fnv1a64（fnv crate）+ Xoshiro256++ Rng（rand_xoshiro）
  page.rs           路径/标题/链接生成 + HTML 标签替换
  assets.rs         --asset-dir 目录扫描，按小写扩展名索引资产字节（无 MIME 白名单，Content-Type 由 mime_guess 猜）
data/
  README.md         数据管线说明
  FORMAT.md         corpus.bin 的字段级格式规约
  corpus.capnp      Cap'n Proto schema（权威字段定义，不随语料内嵌）
  corpus.py         唯一的数据脚本：extract / pack / all / generate
  templates.json    POS 模板（按频率降序）
  word_pools.json   function/content/punct/wordnet 词池
  corpus.bin        打包后的运行时语料（编译期内嵌，或经 --data-file mmap）
assets/
  template.html style.css robots.txt logo.{ico,jpg,png}
```

## 各源模块职责

| 模块 | 职责 |
|------|------|
| `src/main.rs` | 手写参数解析（不用 clap）、`--help` 用法输出、`Assets::from_dir` 与 `Corpus` 加载失败退出 1、按 `--workers` 构建多线程运行时、绑定 `TcpListener`（`--socket` 时改为绑定 `UnixListener`，绑定前先删除残留 socket 文件，绑定后对 socket 做 best-effort 0770 chmod）、打印单行启动日志（含 seed/workers/cache-size/assets 扩展名列表）、`axum::serve` 挂载回退处理器 |
| `src/app.rs` | `Config` / `App` 定义；回退路由（方法、按扩展名的静态资源、未知扩展 404、其余 HTML）；分片缓存；`handle` 请求处理器；`HEAD` 复用 `GET` 的状态与 Content-Length 但返回空 body |
| `src/corpus.rs` | Cap'n Proto 语料加载（v4；`embedded` 内嵌 / `from_file` mmap / `from_owned` 供测试）：加载时用一次性 `Reader<BufferSegments>` 完成逐字段校验（magic/version/偏移单调、UTF-8、池区间、attach 取值等），并把生成所需的索引（词 blob 偏移+长度、`wordOffsets`、`universeLen`、`tagStrings`、`contentOff`/`functionOff`、`punctString`、`contentItems`/`functionItems`、`templateOff`/`templateTags` 以及 `numberTag`/`numberMin`/`numberMax`/`flags`/`attach`）复制进自有 `Vec`，随后丢弃 reader，请求路径不再追随任何 Cap'n Proto 指针；记录数由各偏移列表长度推导（`wordCount = len(wordOffsets) - 1`、`tagCount` 为 `tagStrings`/`punctString`/`attach`/`contentOff`/`functionOff` 的公共长度减一、`templateCount = len(templateOff) - 1`）；词串仍是 mmap/内嵌字节的零拷贝切片，`string` 用 `from_utf8_unchecked`（安全性由加载时对所有词片段的 UTF-8 校验保证）；`generate_sentence_with` 把句子追加进 `&mut String` 并复用 `SentenceScratch`。语料只含词、tag、词池、POS 模板与生成参数；页面模板不在语料内，它是 `--asset-dir` 里唯一的 `.html` 资产 |
| `src/mmap.rs` | 以 `memmap2` 只读映射 `corpus.bin` 并建议 `Advice::Random`；`Mmap::map` 是本仓库两处 `unsafe` 之一（另一处是 `src/corpus.rs` 的 `from_utf8_unchecked`） |
| `src/rng.rs` | `fnv1a64`（`fnv::FnvHasher`）；`Rng` 封装 `Xoshiro256PlusPlus`，提供无偏 `below`（`rand` 的 Lemire `random_range`）、`range_inc`、`usize`、`choice`、`boolean` |
| `src/page.rs` | `PageRenderer`：种子派生、文本生成（word/sentence/header/para/title/name）、`get_main_html`、`add_links_into`、路径与链接辅助函数（posixjoin 语义）、`render` 两遍式标签组装与 `html_escape`；`get_header_into`/`get_para_into`/`add_links_into` 追加进调用方缓冲，`add_links_into` 对无链接边界的连续词段批量拷贝，`escape_page_name`/`push_*` 等辅助直接写入 `&mut String` 避免逐词分配 |
| `src/assets.rs` | 启动时扫描 `--asset-dir`（默认 `assets`）：每个普通文件仅按小写扩展名建索引，值就是字节，不做 MIME 白名单过滤，任意扩展名都接受；唯一的 `html` 文件作为页面模板且不对外提供；目录缺失/不可读、扩展名重复、无扩展名、缺 html 均为启动错误；`content_type(ext)` 用 `mime_guess` 从扩展名猜 Content-Type，未知扩展名回落 `application/octet-stream` |

## 构建、测试与运行

本包由 `pkgs/fastpit/default.nix`（`rustPlatform.buildRustPackage`）构建，是 `nixos-config` 仓库内的一个普通包。从仓库根目录构建/求值：

```
nix-build -E 'with (import <nixpkgs> {}); callPackage ./pkgs/fastpit {}' -o /tmp/fastpit-build
```

在 NixOS 模块里按本仓库惯例调用（示例见 `nixos/optional-apps/pipewire-volume-control.nix`）：

```nix
pkgs.callPackage ./pkgs/fastpit { }
```

`build.rs` 会用 capnpc 编译 `data/corpus.capnp`，因此**构建时 `PATH` 上必须有 Cap'n Proto 编译器**（`default.nix` 的 `nativeBuildInputs` 已加入 `capnproto`）。

Rust 开发在仓库内进行，`PATH` 上的 `cargo` 链接器是坏的，用 `nix-shell` 包一层：

```
nix-shell -p cargo rustc capnproto --run 'cargo run -- --port 8080'
nix-shell -p cargo rustc capnproto --run 'cargo build --release'
```

**资产不内嵌**：`default.nix` 的 `postInstall` 把 `assets/` 装到 `$out/share/fastpit/assets`，部署后的服务必须传 `--asset-dir $out/share/fastpit/assets`；在仓库内直接运行时默认的 `assets` 目录仍然可用。

测试（各模块内置 `#[cfg(test)]` 单元测试，共 32 个）：

```
nix-shell -p cargo rustc capnproto --run 'cargo test'
```

测试覆盖：`fnv1a64` 已知值、`Rng` 可复现与不同种子相异、`below` 有界、`choice` 单元素/空表、内嵌语料非空且模板数/词表数正确、`generate_sentence` 确定性/首字母大写/结尾标点/无残留 `{}`、所有模板 tag 均可渲染、句子不泄露原始 tag、语料内的 flags/numberMin/numberMax 真正驱动生成、`--data-file` 映射结果与内嵌一致、内嵌语料每个词片段均为合法 UTF-8（`from_utf8_unchecked` 的安全前提）、加载后重复访问不受遍历配额限制、损坏语料被拒绝而非 panic、`PageRenderer` 同 `(seed, path)` 输出一致且不同路径有差异、`{NEWTITLE}` 绑定到前一个 `{LINK}`、`escape_page_name` 清洗规则、`normalize_doc_root` 与 `join` 语义、资产扩展名映射与 mime_guess 内容类型、`Assets::from_dir` 对重复扩展名/缺 html/无扩展名的拒绝与对未知扩展名的接受、分片索引有界。

## CLI 参数

| 参数 | 默认 | 含义 |
|------|------|------|
| `--host <ip>` | `127.0.0.1` | 绑定地址 |
| `--port <u16>` | `8080` | 绑定端口 |
| `--socket <path>` | 无 | 绑定 unix socket，替代 TCP；忽略 `--host`/`--port` |
| `--seed <u64>` | `0` | 全局种子/盐 |
| `--document-root <path>` | `/` | 子路径部署前缀 |
| `--workers <n>` | `0` = available_parallelism | tokio worker 线程数 |
| `--cache-size <n>` | `2048` | 缓存页面上限，`0` 关闭 |
| `--asset-dir <path>` | `assets` | 资产目录，按扩展名索引；其中唯一的 `.html` 是页面模板 |
| `--data-file <path>` | 无 | mmap `data/corpus.py pack` 产出的 `corpus.bin`，替代内嵌语料；`corpus.bin` 是唯一支持的语料格式 |
| `--help` | | 用法，退出 0 |

未知参数 -> stderr 打印用法，退出 2。资产目录或 `corpus.bin` 加载失败 -> stderr 打印错误，退出 1。

## 数据管线

`data/` 是离线产物，运行时不依赖 nltk、pycapnp 或 python。管线与格式的完整说明见 `data/README.md`，字段级规约见 `data/FORMAT.md` 与 `data/corpus.capnp`。`data/corpus.py` 是唯一的数据脚本，含四个子命令：

```
python3 data/corpus.py extract   # nltk treebank -> templates.json + word_pools.json
python3 data/corpus.py pack      # JSON -> corpus.bin（Cap'n Proto，pycapnp）
python3 data/corpus.py all       # extract + pack
python3 data/corpus.py generate  # 从 JSON 打印若干条样例句子
```

通用选项：`--templates` / `--pools` / `--out` / `--schema` 指定路径（默认都在脚本同目录），`generate` 另有 `-n/--count` 与 `--seed`。重新生成流程：

```
nltk treebank sample (3,914 parsed sentences)
        │  去掉 trace token，保留 4–22 token 且以 "." 结尾的句子
        ▼
data/templates.json  (1,794 条唯一 POS 序列，按频率降序)

treebank words ──► function 词池（每 tag 取频率前 20）+ content 词池（按屈折形式分 tag）
names corpus ────► NNP 词池（treebank 的专有名词多为股票代码、"j.l." 等噪声）
WordNet ─────────► NN/VB/JJ/RB 的原形词池，增加多样性
        ▼
data/word_pools.json
        │
        │  python3 data/corpus.py pack
        ▼
data/corpus.bin  (Cap'n Proto：编译期内嵌，或经 --data-file mmap)
```

当前语料实测：丢弃 6 条 `LS` 模板后保留 1,788 条模板、43 个 tag、76,270 个去重字符串（其中 71,431 个是词表 universe），文件 1,371,024 字节，sha256 `2214d87d8aeb027c4c0e702213ed7d5e91e4816223d9b9e62918d769a4e6f72a`。改动词池或模板后必须重新运行 `pack` 子命令（并在发布构建中重新编译）；运行时可用 `--data-file <corpus.bin>` 覆盖内嵌语料。

语料是标准 Cap'n Proto 消息，因此服务端不硬编码任何 tag 名或数值范围：`numberTag`/`numberMin`/`numberMax`/`flags`/`attach` 以及各词池、模板都从消息里读；未知字段会被忽略，符合 schema 的其它 `corpus.bin` 可直接替换。`data/corpus.py generate` 是填充规则的 Python 参考实现（用 Python `random`，因此不保证与 Rust 的 Xoshiro256++ 流逐字节相同，只用于演示填充、空格与大小写规则）。

`generate_sentence`（Rust 侧 `src/corpus.rs`）的填充规则与参数来源：

- 从 `templates` 均匀随机取一个模板；模板 tag 全部取自消息。
- 逐 tag 填充：命中 `numberTag` -> `range_inc(numberMin, numberMax)`；命中 punct -> 字面标点；content 池非空 -> 随机词（打包时 `NN`/`VB`/`JJ`/`RB` 已把 `wordnet` 原形并入 content 池）；function 池非空 -> 随机词；否则输出 tag 名本身（打包时已过滤掉这类模板）。
- `flags` bit0 开启时 `a` 在后一词以 `[aeiou]` 开头时变 `an`；bit1 开启时把首个 ASCII 小写字母大写。
- 每对相邻词的拼接方式由该 tag 的 `attach` 值决定：`0` 空格分隔，`1` 贴前词，`2` 贴后词，`3` 两侧贴合；标准语料的映射为 `ATTACH_LEFT = {".", ",", ";", "-RRB-", "''", "POS"}`、`ATTACH_RIGHT = {"-LRB-", "``", "$"}`、`ATTACH_BOTH = {"HYPH"}`。
- 打包阶段丢弃含「无对应词池且不是数值槽的 tag」的模板（treebank 的 `LS` 共 6 条，1794 -> 1788），避免原始 tag 进入正文。

`word_universe` 为 content（含合并的 wordnet）与 function 的并集，仅保留非空、纯 ASCII 小写字母 `^[a-z]+$`、长度 `>= 2` 的词，去重排序并放在字符串表最前面，供 `get_word`、标题、人名与链接使用。

## 确定性与种子设计

- 请求种子：`Rng::new(fnv1a64(path.as_bytes()) ^ seed.wrapping_mul(0x9E3779B97F4A7C15))`。
- 同一路径 + 同一 `--seed` 必然得到相同字节，跨重启、与缓存命中无关。
- 不同路径互不相同；改 `--seed` 整体改变站点内容。
- `Rng` 已换成 `rand_xoshiro` 的 `Xoshiro256++`（种子经 `seed_from_u64` 派生），不再是早期手写的 SplitMix64：**同一 `(seed, path)` 生成的正文与旧版本不同**，但确定性、跨重启一致性与缓存无关性不变。
- `rng.rs` 的 `below` 走 `rand` 的 `random_range`（Lemire 加宽乘法 + 拒绝采样）保持无偏；所有生成路径都是纯函数式的，只依赖 RNG 流与只读语料。
- 页面缓存只做加速，不改变任何输出；命中与未命中结果一致。

## 性能设计

- tokio 多线程运行时，`--workers 0` 时使用 `available_parallelism`。
- `App` 以 `Arc` 共享；语料索引、资产与模板只读，无需锁。
- **读路径上不允许共享原子操作。** `capnp` 的 `sync_reader` 特性已移除；语料在加载时被一次性遍历并校验，所需的索引复制为自有 `Vec`（词 blob 偏移+长度、`wordOffsets`、`tagStrings`、`contentOff`/`functionOff`、`punctString`、`templateOff`/`templateTags`、生成参数等），reader 随即丢弃。因此请求路径不追随任何 Cap'n Proto 指针，也就不会碰到 `sync_reader` 的共享 `AtomicUsize` `ReadLimiter`。
- 语料用 `memmap2` 映射文件或直接内嵌；词串/模板仍是底层缓冲的零拷贝 `&str` 切片（`Corpus::string` 以 `from_utf8_unchecked` 取出，正确性由加载时逐词片段的 UTF-8 校验保证），词池不被复制。
- **渲染为两遍式且复用缓冲区。** 第一遍按文档顺序完成全部 RNG 抽样并保存结果，第二遍一次性组装页面；`SentenceScratch` 在页内所有句子间复用，`get_header_into`/`get_para_into`/`add_links_into` 追加进调用方缓冲，`add_links_into` 对无链接边界的连续词段批量拷贝。
- 响应缓存分 32 个分片：`fnv1a64(path) % 32`，每片一个 `Mutex<HashMap<String, Bytes>>`，锁仅覆盖一次 get/insert。每片容量 `max(1, cache_size / 32)`；写满时先清空该分片（热路径在两次清空之间保留，内存有界）。命中时克隆 `Bytes`（仅原子引用计数增减，无拷贝），O(1)。
- release 使用 LTO + `codegen-units = 1`。

性能基线可复现：`wrk -s /tmp/rand.lua`（随机路径）配合 `--cache-size 0`，单页 CPU 取 `/proc/PID/stat` 的 `utime + stime` 再除以请求数。16 vCPU i7-11800H、回环、release、`--seed 7`、`wrk -c 64` 跑 6 秒的实测（改前 -> 改后）：

| workers | 改前 req/s | 改前 CPU/页 | 改后 req/s | 改后 CPU/页 |
|--------:|-----------:|------------:|-----------:|------------:|
| 1       | 438        | 2.25 ms     | 3,314      | 0.29 ms     |
| 2       | 411        | 4.82 ms     | 6,381      | 0.30 ms     |
| 4       | 279        | 14.18 ms    | 12,268     | 0.31 ms     |
| 8       | 293        | 27.06 ms    | 22,759     | 0.34 ms     |
| 16      | 241        | 63.82 ms    | 33,775     | 0.42 ms     |

改前每页 CPU 随 worker 数线性增长而吞吐量停留在 ~250 req/s：`sync_reader` 的 `ReadLimiter` 是 `AtomicUsize`，每次指针追随都在同一条 cache line 上做一次 load 加一次 store，所有 worker 在同一条 line 上反复争抢。默认缓存（`--cache-size 2048`）下，`oha` 实测缓存页 c=1 为 45,630 req/s、c=64 为 176,366 req/s；未缓存渲染路径 c=64 为 31,962 req/s、c=4096 为 24,031 req/s。

## 内嵌资源规则

只有**语料**是编译期内嵌的：`src/corpus.rs` 的 `embedded()` 用 `include_bytes!("../data/corpus.bin")` 把语料放进二进制。**资产不再内嵌**：`src/assets.rs` 在启动时扫描 `--asset-dir`（默认 `assets`）目录，按扩展名索引并读取文件内容。

因此：

- `data/corpus.capnp`、`data/corpus.bin` 必须在构建时存在；`default.nix` 以 `src = ./.` 纳入整个包目录。
- `assets/` 必须在运行时存在：二进制不带资产，`default.nix` 的 `postInstall` 将其装到 `$out/share/fastpit/assets`，部署时要传 `--asset-dir $out/share/fastpit/assets`（或自带资产目录）；单元测试也直接读取 `assets/` 目录，因此构建环境的源码树里同样需要它。
- 改动词池或模板后必须重新运行 `python3 data/corpus.py pack` 并重新编译才能生效；运行时可用 `--data-file <corpus.bin>` 覆盖语料，用 `--asset-dir <dir>` 覆盖资产，均不改变生成结果。
- `Cargo.lock` 必须提交，`default.nix` 的 `cargoLock.lockFile` 依赖它。

## 编码约定

- Rust 2021 edition。
- 依赖保持精简：`axum 0.8`、`tokio 1`（`rt-multi-thread`、`net`）、`capnp 0.25`（仅 `unaligned`）、`memmap2 0.9`、`rand 0.9`、`rand_xoshiro 0.7`、`fnv 1`、`mime_guess 2`；构建依赖 `capnpc 0.25`。CLI 手写，不引入 clap。
- `unsafe` 只允许两处：`src/mmap.rs` 的 `memmap2::Mmap::map`，以及 `src/corpus.rs` 的 `core::str::from_utf8_unchecked`（其安全性由加载时对每个词片段的 UTF-8 校验保证）。
- 热路径上除分片 `Mutex` 外不允许全局锁。
- `{MAIN}` 生成的 HTML 不转义；仅对动态文本值做 `html_escape`（`& < > "`）。
- 注释只解释非显然的「为什么」，不复述代码本身。
