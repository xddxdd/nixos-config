{
  pkgs,
  lib,
  ...
}:
let
  # Must be running >1min so that node_exporter can see them running
  periodicTasks = [
    # keep-sorted start
    "auto-mihoyo-bbs"
    "bilibili-tool-pro"
    # keep-sorted end
  ];
in
{
  services.prometheus.ruleFiles = [
    (pkgs.writeText "periodic-tasks.rules" (
      builtins.toJSON {
        groups = [
          {
            name = "periodic_tasks";
            rules = builtins.map (svc: {
              alert = "periodic_${lib.replaceStrings [ "-" "." ] [ "_" "_" ] svc}";
              expr = ''sum(max_over_time(node_systemd_unit_state{name="${svc}.service",state!~"(deactivating|inactive|failed)"}[24h])) == 0'';
              for = "5m";
              labels.severity = "warning";
              annotations = {
                summary = "⚠️ ${svc}: Periodic job not running.";
                description = "${svc} hasn't run for 24 hours.";
              };
            }) periodicTasks;
          }
        ];
      }
    ))
  ];
}
