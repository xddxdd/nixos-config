{
  inputs,
  ...
}:
{
  imports = [ inputs.vscode-server.homeModules.default ];

  services.vscode-server = {
    enable = true;
    enableFHS = false;
  };
}
