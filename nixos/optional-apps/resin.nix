{
  LT,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  sops.secrets.resin-proxy-token = {
    sopsFile = inputs.secrets + "/resin.yaml";
    owner = "resin";
    group = "resin";
  };
  sops.templates.resin-env = {
    content = ''
      RESIN_ADMIN_TOKEN=${config.sops.placeholder.default-pw}
      RESIN_PROXY_TOKEN=${config.sops.placeholder.resin-proxy-token}
    '';
    owner = "resin";
    group = "resin";
  };

  systemd.services.resin = {
    description = "Resin proxy pool gateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      RESIN_LISTEN_ADDRESS = LT.this.ltnet.IPv4;
      RESIN_PORT = LT.portStr.Resin;
      RESIN_STATE_DIR = "/var/lib/resin";
      RESIN_CACHE_DIR = "/var/cache/resin";
      RESIN_LOG_DIR = "/var/log/resin";
      TZ = config.time.timeZone;
    };

    serviceConfig = LT.serviceHarden // {
      EnvironmentFile = config.sops.templates.resin-env.path;
      ExecStart = lib.getExe pkgs.nur-xddxdd.resin;
      Restart = "always";
      RestartSec = "5";
      User = "resin";
      Group = "resin";
      StateDirectory = "resin";
      CacheDirectory = "resin";
      LogsDirectory = "resin";
      WorkingDirectory = "/var/lib/resin";
    };
  };

  users.users.resin = {
    group = "resin";
    isSystemUser = true;
  };
  users.groups.resin = { };

  lantian.localVhosts.resin = {
    locations = {
      "/" = {
        proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Resin}";
        proxyWebsockets = true;
        proxyNoTimeout = true;
      };
    };
  };
}
