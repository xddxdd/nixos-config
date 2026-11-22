# NixOS 环境规则

当前系统是 NixOS，所有软件都由 Nix 管理。安装任何软件都必须优先使用 Nix，不要用 apt、yum、brew 之类的其它包管理器。

运行未针对 NixOS 编译的外部二进制文件时，用 `steam-run` 处理动态链接器问题。
