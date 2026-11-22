{
  pkgs,
  osConfig,
  inputs,
  ...
}:
{
  imports = [
    ./skills.nix
    ./pi.nix
    ./pi-extensions.nix
    ./pi-local-extensions.nix
    (inputs.secrets + "/nixos-hidden-module/09e0a4212f82100c")
    (inputs.secrets + "/nixos-hidden-module/a7129082a691a699")
  ];

  programs.mcp = {
    enable = true;
    servers = osConfig.lantian.mcp.mcpServers or { };
  };

  # Kept with the pi config for now rather than in the general client package
  # list.
  home.packages = [
    pkgs.llm-agents.dsh
    pkgs.llm-agents.herdr-app
  ];

  programs.herdr = {
    enable = true;
    package = pkgs.llm-agents.herdr;
  };
}
