{
  lib,
  osConfig,
  ...
}:
{
  home.file.".picoclaw/mcp.json".text = builtins.toJSON {
    mcpServers = lib.mapAttrs (k: v: v // { enabled = true; }) (osConfig.lantian.mcp.mcpServers or { });
  };
}
