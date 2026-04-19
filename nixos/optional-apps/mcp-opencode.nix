{
  config,
  pkgs,
  ...
}:
let
  targetPath = "/home/lantian/.config/opencode/opencode.json";
in
{
  imports = [ ./mcp-servers.nix ];

  systemd.services.mcp-opencode-setup = {
    description = "Setup OpenCode MCP config";
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "lantian";
      Group = "users";
      RuntimeDirectory = "mcp-opencode-setup";
    };

    path = [ pkgs.jq ];

    script = ''
      ${config.lantian.mcp.toOpenCodeJSON "/run/mcp-opencode-setup/mcp.json"}

      # Read MCP config
      mcpConfig=$(cat /run/mcp-opencode-setup/mcp.json)

      # Merge into existing opencode.json
      if [ -f "${targetPath}" ]; then
        tmpFile="/run/mcp-opencode-setup/opencode.json"
        jq --argjson mcp "$mcpConfig" '.mcp = $mcp' "${targetPath}" > "$tmpFile"
        mv "$tmpFile" "${targetPath}"
      else
        echo "{\"mcp\": $mcpConfig}" > "${targetPath}"
      fi
    '';
  };
}
