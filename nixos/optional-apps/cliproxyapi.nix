{
  pkgs,
  lib,
  LT,
  ...
}:
{
  systemd.services.cliproxyapi = {
    description = "CLIProxyAPI";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = lib.getExe pkgs.llm-agents.cli-proxy-api;
      Restart = "always";
      RestartSec = "3";

      StateDirectory = "cliproxyapi";
      WorkingDirectory = "/var/lib/cliproxyapi";

      User = "cliproxyapi";
      Group = "cliproxyapi";
    };
  };

  users.users.cliproxyapi = {
    group = "cliproxyapi";
    isSystemUser = true;
  };
  users.groups.cliproxyapi.members = [ "nginx" ];

  lantian.localVhosts.cliproxyapi = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
      proxyNoTimeout = true;
      proxyOverrideHost = "localhost";
    };
  };
}
