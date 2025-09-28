{ config, ... }:
let
  targetPath = "/home/lantian/.config/Code/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json";
in
{
  imports = [ ./mcp-servers.nix ];

  systemd.services.mcp-roo-code-setup = {
    description = "Setup Roo Code config";
    after = [ "agenix-install-secrets.service" ];
    requires = [ "agenix-install-secrets.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "lantian";
      Group = "users";
    };

    script = ''
      mkdir -p "$(dirname "${targetPath}")"
      ${config.lantian.mcp.toJSON targetPath}
    '';
  };
}
