# 脚本编写精简规则

## 适用范围

本规则仅适用于**脚本编写**任务，不适用于完整项目开发。

判定标准：

- 脚本：单个文件，用于完成特定自动化任务
- 完整项目：包含多个文件、模块化结构、需要文档和测试

## 核心要求

### 1. 只创建脚本本身

- **不要创建 README 文件**
- **不要创建额外的文档文件**
- **不要创建示例配置文件**（除非用户明确要求）

除非用户特别要求，否则只输出脚本文件本身。

### 2. 保持脚本精简

脚本应当简洁高效，避免冗余：

**不必要的日志输出**：

```bash
# 不需要
echo "Starting process..."
echo "Processing item 1..."
echo "Done!"

# 只需要
# （直接执行核心逻辑）
```

**不必要的异常处理**：

```bash
# 不需要（对于简单脚本）
if [ ! -f "$file" ]; then
    echo "Error: File not found"
    exit 1
fi

# 只需要
# （直接使用，让脚本自然失败）
cat "$file"
```

### 3. 精简原则

保留必要内容：

- 核心业务逻辑
- 关键的参数处理
- 必要的依赖检查（如果脚本依赖特定环境）

移除冗余内容：

- 详细的进度日志
- 过度的错误处理
- 冗长的注释说明
- 帮助信息（除非用户要求）

## 示例对比

### 过度设计的脚本

```bash
#!/bin/bash
# 脚本名称：backup.sh
# 功能：备份指定目录
# 作者：xxx
# 日期：xxx
# 用法：./backup.sh <source> <dest>

set -e

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 错误处理
error() {
    log "ERROR: $1"
    exit 1
}

# 检查参数
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source> <dest>"
    exit 1
fi

SOURCE="$1"
DEST="$2"

log "Starting backup..."
log "Source: $SOURCE"
log "Destination: $DEST"

if [ ! -d "$SOURCE" ]; then
    error "Source directory does not exist"
fi

log "Copying files..."
rsync -av "$SOURCE/" "$DEST/"

log "Backup completed successfully"
```

### 精简后的脚本

```bash
#!/bin/bash
rsync -a "${1:?}" "${2:?}"
```

## 例外情况

以下情况需要保留更多内容：

1. **用户明确要求**：添加日志、错误处理、帮助信息等
2. **复杂逻辑**：脚本包含复杂的控制流，需要适当的注释
3. **安全关键**：涉及数据删除、系统配置等操作，需要确认步骤
4. **生产环境**：脚本将用于生产环境，需要健壮性保障

## 判断流程

```
用户要求写脚本
    ↓
是否明确要求文档/README？
    ├─ 是 → 创建脚本 + 文档
    └─ 否 → 只创建脚本
         ↓
    脚本是否用于生产环境？
         ├─ 是 → 保留必要的错误处理
         └─ 否 → 保持精简
              ↓
         只保留核心逻辑
```
