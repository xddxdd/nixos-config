# 机器本地秘密文件

`lantian.secrets.<name>` 只声明生成方式和文件属性；值在机器启动时生成，不进入 Nix store。

```nix
{
  lantian.secrets.example = {
    # 默认路径为 /var/lib/lantian-secrets/example。
    command = "pwgen -s 48 1";
    owner = "lantian";
    group = "users";
    mode = "0640";
  };
}
```

支持 `path`、`command`、`owner`、`group`、`mode` 和 `audit`。默认命令是 `pwgen -s 64 1`，默认属主/属组为 root、模式为 0600。`pwgen` 已加入服务 PATH；其他生成工具应使用 `${pkgs.<package>}/bin/<command>` 等明确路径。

- 命令的标准输出成为文件内容；命令文本是公开的 store 内容，不能嵌入已有凭据。
- 每个命令在独立临时目录运行，必须成功且输出非空。标准输出和错误输出都不会进入 journal。
- 已有文件不会重新生成，包括空文件；每次服务执行仍会修正其 owner/group/mode。
- 原子发布不替换并发创建的文件；拒绝路径中的符号链接、非普通文件和有额外硬链接的文件。已有父目录的权限不变，新父目录由指定用户拥有且模式为 0700。
- owner/group 必须已经存在。消费者可通过 `after`/`requires = [ "lantian-secrets.service" ]` 明确依赖生成服务；不要在 Nix 求值中读取文件内容。
- 默认目录在本项目已持久化的 `/var/lib` 中。自定义到临时根文件系统的路径会在重启后重新生成，因为文件已经不存在；本模块不会为了保留旧值接管其他目录或覆盖现有凭据。

## 诱饵和审计

`nixos/minimal-components/decoy-secrets.nix` 声明 8 个独立诱饵：SSH、AWS、PostgreSQL、MySQL、GitHub、npm、备份环境文件，以及用户目录的 AWS 备份。它们使用 `.bak` 后缀，不会被默认 SSH/SDK/数据库客户端当作现役凭据读取；生成的密钥没有注册到任何服务。已有同名文件保留内容，权限按声明修正。

`audit = true` 将该文件交给 `nixos/minimal-components/auditd.nix` 审计，使用 `credential-access` key，并且不按 UID 排除调用者。

其他规则：

| key | 范围 |
| --- | --- |
| `service-home` | `/home`、`/root` 及已挂载子树；实际、有效或文件系统 UID 任一处于 1–999 |
| `persistent-access` | `/nix/persistent` 及已挂载子树；实际、有效或文件系统 UID 任一处于 1–999 |
| `access-denied` | 所有 UID 的 EACCES/EPERM；覆盖因祖先目录不可遍历而无法匹配 inode 的尝试，也会记录其他路径的权限拒绝 |

规则声明在 `security.audit.rules` 中，由 NixOS 原生 `auditctl -R` 服务加载，没有自定义加载脚本。文件规则、服务 UID 的 home/root 规则、持久目录规则依次匹配；规则在本地文件系统和秘密文件就绪后加载，内核会标记此时已挂载的子树，已监视 inode 的 bind 别名也会命中。之后新挂入的独立文件系统仍需重新加载规则或配置等价关系，不能假定自动覆盖。原生规则文件按空白分词，因此 `audit = true` 的文件路径不能包含空白字符；不启用审计的生成路径没有这个限制。

记录保存在 `/var/log/audit/audit.log`，单文件 25 MiB、轮转保留 5 份。syslog 转发和 `systemd-journald-audit.socket` 都保持关闭，避免两条独立路径把审计记录送回 journald。运行中的 journald 会保留已继承的 netlink FD，因此 `journald.nix` 在 socket 路由变化时触发重启；仅 mask socket 不能完成在线切换。日志包含访问路径、身份和命令行，应当作为敏感日志管理；不记录文件正文，但命令行本身也可能含敏感信息。

`nixos/minimal-components/audit-loki.nix` 启动独立 Fluent Bit，直接读取原生 audit 文件并发送到现有 LTnet Loki，标签为 `job="audit",host="<主机名>"`。它用 DynamicUser（61184–65519）运行，启动时验证 UID 大于 999，因此读取和持久化队列操作不匹配服务 UID 范围。只授予 confined 根内读取 root 私有日志所需的 `CAP_DAC_READ_SEARCH`，原生日志保持只读。该实例不读取 journald；自身诊断写入 `/run/audit-loki/forwarder.log`，标准输出/错误不回送 journal，避免诊断再触发普通日志转发器。

接收端 Loki 同样不能用受监视的 UID 写入持久目录。本项目的 `loki.nix` 使用独立 `loki-collector` 账户（UID 60000），保持原 Loki group 和 socket 权限。固定版本的 userborn 不修改已有账户的 UID，所以迁移使用新账户，由 systemd `StateDirectory` 迁移既有数据树的属主，不删除或重建数据。普通 journald 日志仍由原 Fluent Bit 转发。

读取位置和队列保存在 `/var/lib/audit-loki`，内存映射块数受限，磁盘队列上限 64 MiB；临时诊断文件有轮转。网络失败会重试，但这不是无限期或零丢失承诺：长时间离线、队列满、轮转竞争或本地 audit 丢失都可能造成缺口。Loki 时间戳是转发读取时间，原始内核事件时间仍在文本中。完整性的本地依据仍是 auditd 文件和 `auditctl -s` 的 lost/backlog，而不是仅看 Loki 是否有记录。

同一 inode 可经持久化 bind 别名访问，多条规则重叠时只保留第一个匹配的 key；例如持久 home 子树的服务 UID 访问会记录为 `service-home`，不会额外产生一条 `persistent-access` 副本。应结合记录的路径和 UID 分析，而不是把单一 key 当作全部访问的集合。

这些是内核文件操作审计规则，不是逐字节读取跟踪：已建立的 mmap 等内存访问不会逐次生成文件访问记录。限定 UID 后仍可能产生大量日志；未部署前的 VM 测试不能替代生产负载验证。root/普通用户的成功访问不匹配 `persistent-access`，但独立的全 UID 诱饵规则和权限拒绝规则仍会记录相应访问。

## 本机 snakeoil TLS

`nixos/minimal-components/snakeoil-tls.nix` 声明 `lantian.secrets.tls-snakeoil`：每机生成独立 RSA 3072 位私钥和 10 年自签证书，同一原子发布的 PEM 保存成对的材料。默认持久路径为 `/var/lib/lantian-secrets/tls-snakeoil`；启用 nginx 时为 `root:nginx`（实际配置的 nginx group）0640，否则为 root:root 0600。它不声明专用审计规则；通用的持久目录规则仍按调用者 UID 生效。

nginx 的 snakeoil 分支用此文件替代 secrets repo 的共享私钥/证书；显式配置的 ACME/其他证书不变。nginx 及其配置重载服务等待生成服务，confined 根也只读绑定该文件。已有 bundle 不重生成，也不自动续期或轮换；有意换证需要单独维护。自签材料没有因此加入系统信任库。

## 验证

```sh
PYTHONDONTWRITEBYTECODE=1 python3 nixos/minimal-modules/secrets/test_generate.py
nix build --impure --no-link --file nixos/minimal-modules/secrets/tests.nix
```

第二条启动一次性 NixOS 测试 VM，不激活任何生产主机配置。它检查生成/不重生成、权限恢复、有效/文件系统 UID、边界 UID、`service-home`/`persistent-access` 对 root/普通用户的排除、诱饵读取、拒绝访问、子挂载/bind 别名、auditd 重启、零丢失计数和重启后的持久值。还验证独立转发器的 UID、mock Loki 实际接收、故障期间缓存后补送且不审计自身、key/certificate 配对、nginx TLS 握手及证书跨重启持久化。

新文件尚未进入 Git 索引时，用 `path:$PWD` 的 flake 引用求值；Git flake 只包含已跟踪文件。
