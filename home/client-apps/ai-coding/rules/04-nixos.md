# NixOS 环境规则

## 系统环境

当前系统为 **NixOS**，使用 Nix 包管理器管理所有软件。

## 软件安装

### 优先使用 Nix 安装

需要安装任何软件时，**必须优先使用 Nix**，而非其他包管理器（如 apt、yum、brew 等）。

### 禁止的操作

- **不要**使用 `apt`、`yum`、`dnf`、`pacman` 等非 Nix 包管理器
- **不要**从源码手动 `make install`
- **不要**使用 `curl | sh` 等方式安装软件

### 禁止从根目录搜索

- **不要**执行 `find /`、`grep -r /`、`fd /`、`rg /` 等从根目录（`/`）开始的搜索命令
- 在 NixOS 上，`/nix/store` 包含大量文件，从根目录遍历会极其缓慢，可能耗时数分钟甚至卡死
- 需要搜索时，应限定在具体目录内，例如 `find /etc`、`rg . /home/user/project`
- 如需查找系统文件，优先使用 `which`、`whereis`、`nix-locate` 等针对性工具

## devShell 集成

### 判断是否应加入 devShell

如果当前项目包含 flake.nix 并使用 flake-parts 管理输出，并且某个工具满足以下条件，应考虑将其加入 devShell：

1. **会重复使用**：非一次性需求
2. **与项目开发相关**：用于构建、检查、部署等开发流程
