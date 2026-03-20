lib:
{ pkgs, ... }:
{
  # Claude Code 环境变量
  # 参考: https://linux.do/t/topic/1513988
  home.packages = with pkgs; [
    claude-code
  ];

  home.sessionVariables = {
    # keep-sorted start
    CLAUDE_CODE_ATTRIBUTION_HEADER = "0"; # 禁用账单归属头
    
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"; # 禁用非必要流量
    CLAUDE_CODE_PROXY_RESOLVES_HOSTS = "1"; # 将 DNS 解析交给代理服务器
    DISABLE_INSTALLATION_CHECKS = "1"; # 禁用安装检查
    ENABLE_TOOL_SEARCH = "1"; # 强制开启 tool search (2.1.72+)
    # keep-sorted end
  };
}