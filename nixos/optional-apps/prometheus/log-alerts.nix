{ LT, ... }:
{
  services.vmalert.instances.logs = {
    enable = true;
    settings = {
      "httpListenAddr" = "127.0.0.1:${LT.portStr.Prometheus.VMAlertLogs}";
      "evaluationInterval" = "15s";
      "datasource.url" = "http://${LT.hosts.colocrossing.ltnet.IPv4}:${LT.portStr.VictoriaLogs}";
      "notifier.url" = [ "http://127.0.0.1:${LT.portStr.Prometheus.AlertManager}" ];
      "disableAlertgroupLabel" = true;
    };
    rules.groups = [
      {
        name = "service-tripwire";
        type = "vlogs";
        rules = [
          {
            alert = "service_tripwire_execution";
            # Count only syscall records; enriched auditd logs append fields after ASCII GS.
            expr = ''
              {job="audit"} _time:5m
              _msg:~"^type=SYSCALL " _msg:~" key=\"exec-tripwire\"( |\\x1d|$)"
              | stats by (host) count() as attempts
              | filter attempts:>0
            '';
            labels = {
              severity = "critical";
              instance = "{{ $labels.host }}";
            };
            annotations = {
              summary = "Tripwire command executed on {{ $labels.host }}";
              description = "{{ $value }} tripwire executions were recorded in the last five minutes. Inspect the host's audit trail for arguments and process IDs.";
            };
          }
        ];
      }
    ];
  };

  systemd.services.vmalert-logs = {
    wants = [ "alertmanager.service" ];
    after = [ "alertmanager.service" ];
    serviceConfig.RestartSec = "5s";
  };
  lantian.harden.vmalert-logs = {
    enable = true;
    etc."vmalert-logs/rules.yml" = true;
  };
}
