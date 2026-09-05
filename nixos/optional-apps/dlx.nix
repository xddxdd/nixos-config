{
  pkgs,
  lib,
  LT,
  config,
  inputs,
  ...
}:
let
  dlx = pkgs.nur-xddxdd.dlx.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/dlx-fingerprint.patch
    ];
  });
in
{
  sops.secrets.dlx-proxy-user = {
    sopsFile = inputs.secrets + "/dlx.yaml";
    owner = "dlx";
    group = "dlx";
  };
  sops.secrets.dlx-proxy-pass = {
    sopsFile = inputs.secrets + "/dlx.yaml";
    owner = "dlx";
    group = "dlx";
  };
  sops.templates.dlx-env = {
    content = ''
      PROXY=http://${config.sops.placeholder.dlx-proxy-user}:${config.sops.placeholder.dlx-proxy-pass}@${LT.this.ltnet.IPv4}:${LT.portStr.Resin}
    '';
    owner = "dlx";
    group = "dlx";
  };

  systemd.services.dlx = {
    description = "DLX";
    wantedBy = [ "multi-user.target" ];

    environment = {
      IP = "127.0.0.1";
      PORT = LT.portStr.DLX;
    };

    serviceConfig = LT.serviceHarden // {
      EnvironmentFile = config.sops.templates.dlx-env.path;
      ExecStart = lib.getExe dlx;
      User = "dlx";
      Group = "dlx";

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.dlx = {
    group = "dlx";
    isSystemUser = true;
  };
  users.groups.dlx = { };

  lantian.localVhosts.dlx = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.DLX}";
        proxyNoTimeout = true;
      };
    };
  };
}
