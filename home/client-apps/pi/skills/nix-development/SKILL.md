---
name: nix-development
description: 创建 Nix Flake，或为 Nix 项目选择开发工具与配置 devShell 时使用。使用 flake-parts 管理 outputs，并将重复使用的开发工具纳入适用的 devShell。
---

# Nix Flake 与 devShell 开发规则

## 创建 Flake

当被要求创建 Nix Flake 时，**必须使用 flake-parts** 管理 outputs，而非 flake-utils。

## devShell 集成

### 判断是否应加入 devShell

如果当前项目包含 flake.nix 并使用 flake-parts 管理输出，并且某个工具满足以下条件，应考虑将其加入 devShell：

1. **会重复使用**：非一次性需求
2. **与项目开发相关**：用于构建、检查、部署等开发流程
