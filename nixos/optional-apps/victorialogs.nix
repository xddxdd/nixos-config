{
  config,
  lib,
  LT,
  ...
}:
let
  collectorUser = "victorialogs-collector";
  collectorGroup = "victorialogs";
  allowAddresses = addresses: ''
    ${lib.concatMapStringsSep "\n" (ip: "allow ${ip};") addresses}
    deny all;
  '';
  proxyLocation = {
    # 不带 URI，保留 JSON 摄取和 LogsQL 查询的原始路径。
    proxyPass = "http://127.0.0.1:9428";
    proxyNoTimeout = true;
  };
  queryLocation = proxyLocation // {
    extraConfig = allowAddresses [
      LT.hosts.terrahost.ltnet.IPv4
      LT.hosts.terrahost.ltnet.IPv6
    ];
  };
in
{
  services.victorialogs = {
    enable = true;
    listenAddress = "127.0.0.1:9428";
    extraOptions = [ "-retentionPeriod=30d" ];
  };

  # 固定宿主机 UID，避开审计监控的 1-999 和 DynamicUser 范围，防止日志回环。
  users.users.${collectorUser} = {
    isSystemUser = true;
    uid = 60001;
    group = collectorGroup;
    createHome = lib.mkForce false;
  };
  users.groups.${collectorGroup} = { };

  systemd.services.victorialogs.serviceConfig = {
    User = collectorUser;
    Group = collectorGroup;
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    # 保留上游加固和状态目录权限，仅将持久化目录绑定进完整单元的隔离环境。
    StateDirectoryMode = "0700";
    RestartSec = lib.mkForce "5s";
    BindPaths = [ "/var/lib/${config.services.victorialogs.stateDir}" ];
  };
  lantian.harden.victorialogs.enable = true;

  lantian.firewall.zones = {
    LTNET.tcpPorts."${LT.portStr.VictoriaLogs}".type = "local";
  };

  lantian.nginxVhosts.victorialogs = {
    listenHTTP = {
      enable = true;
      port = LT.port.VictoriaLogs;
      default = true;
    };
    listenHTTPS.enable = false;
    accessibleBy = "private";
    accessBlockAction = "=404 /";
    enableCommonLocationOptions = false;
    noIndex.serveRobotsTxt = false;
    locations = {
      "/".return = 404;
      "= /insert/jsonline" = proxyLocation // {
        # location ACL 替换服务器 ACL，不继承 private 默认允许的回环地址。
        extraConfig = allowAddresses (LT.constants.ltnet.IPv4 ++ LT.constants.ltnet.IPv6);
      };
    }
    // lib.genAttrs [
      "= /select/logsql/query_time_range"
      "= /select/logsql/facets"
      "= /select/logsql/field_names"
      "= /select/logsql/field_values"
      "= /select/logsql/hits"
      "= /select/logsql/query"
      "= /select/logsql/stats_query"
      "= /select/logsql/stats_query_range"
      "= /select/logsql/stream_field_names"
      "= /select/logsql/stream_field_values"
      "= /select/logsql/stream_ids"
      "= /select/logsql/streams"
      "= /select/logsql/tail"
      "= /metrics"
    ] (_: queryLocation);
  };
}
