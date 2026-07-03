{ pkgs, ... }:
{
  services.clickhouse = {
    enable = true;
    package = pkgs.clickhouse-lts;

    # With changes from https://theorangeone.net/posts/calming-down-clickhouse/
    extraServerConfig = ''
      <?xml version="1.0"?>
      <clickhouse>
        <logger>
          <level>warning</level>
          <console>true</console>
        </logger>
        <query_thread_log remove="remove"/>
        <query_log remove="remove"/>
        <text_log remove="remove"/>
        <trace_log remove="remove"/>
        <metric_log remove="remove"/>
        <asynchronous_metric_log remove="remove"/>

        <!-- Update: Required for newer versions of Clickhouse -->
        <session_log remove="remove"/>
        <part_log remove="remove"/>

        <!-- Force timezone for Plausible Analytics -->
        <timezone>UTC</timezone>
      </clickhouse>
    '';

    extraUsersConfig = ''
      <?xml version="1.0"?>
      <clickhouse>
        <profiles>
          <default>
            <log_queries>0</log_queries>
            <log_query_threads>0</log_query_threads>
          </default>
        </profiles>
      </clickhouse>
    '';
  };
}
