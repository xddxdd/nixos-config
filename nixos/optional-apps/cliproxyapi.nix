{
  pkgs,
  lib,
  LT,
  ...
}:
let
  # Patched cli-proxy-api (numtide/llm-agents.nix):
  # A provider prefix makes the prefixed ID the only registered model name, so
  # bare upstream names are never listed or routed. Two providers therefore
  # cannot share one registry entry when a provider's model name happens to
  # equal another provider's prefix plus model name.
  # doCheck is off because upstream tests assert that bare names stay registered.
  cli-proxy-api = pkgs.llm-agents.cli-proxy-api.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/cliproxyapi-prefix-only-models.patch
    ];
    doCheck = false;
    doInstallCheck = false;
  });
in
{
  systemd.services.cliproxyapi = {
    description = "CLIProxyAPI";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = lib.getExe cli-proxy-api;
      Restart = "always";
      RestartSec = "3";

      StateDirectory = "cliproxyapi";
      WorkingDirectory = "/var/lib/cliproxyapi";

      User = "cliproxyapi";
      Group = "cliproxyapi";
    };
  };
  lantian.harden.cliproxyapi.enable = true;

  users.users.cliproxyapi = {
    group = "cliproxyapi";
    isSystemUser = true;
  };
  users.groups.cliproxyapi.members = [ "nginx" ];

  lantian.nginxVhosts = {
    "ai-api.xuyh0120.win" = {
      locations = {
        "/".return = "404";
        "/v1/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
      };

      accessibleBy = "public";
      sslCertificate = "lets-encrypt-xuyh0120.win";
      noIndex.enable = true;
    };
    "cliproxyapi.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
        "= /".return = "302 /management.html";
      };

      accessibleBy = "private";
      sslCertificate = "lets-encrypt-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
