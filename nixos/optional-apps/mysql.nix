{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
let
  mysqlenv-common = pkgs.buildEnv {
    name = "mysql-path-env-common";
    pathsToLink = [ "/bin" ];
    paths = with pkgs; [
      bash
      gawk
      gnutar
      inetutils
      which
    ];
  };
  mysqlenv-rsync = pkgs.buildEnv {
    name = "mysql-path-env-rsync";
    pathsToLink = [ "/bin" ];
    paths = with pkgs; [
      lsof
      procps
      rsync
      stunnel
    ];
  };
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
        binlog_format = "ROW";
        default-storage-engine = "innodb";
        enforce_storage_engine = "innodb";
        innodb_autoinc_lock_mode = 2;
        innodb_file_per_table = 1;
        innodb_flush_method = "fsync";
        innodb_lock_wait_timeout = 100;
        innodb_read_only_compressed = 0;
        innodb_use_native_aio = false;
        max_connections = 10000;
        performance_schema = false;
      };

      # Disable galera for now
      galera = lib.mkIf false {
        wsrep_on = true;
        wsrep_retry_autocommit = 3;
        wsrep_provider = "${pkgs.mariadb-galera}/lib/galera/libgalera_smm.so";
        wsrep_cluster_name = "lantian";
        wsrep_cluster_address =
          "gcomm://"
          + lib.concatMapStringsSep "," (n: LT.hosts."${n}".ltnet.IPv4) [
            "colocrossing"
            "lt-home-vm"
            "terrahost"
            "virmach-ny6g"
          ];
        wsrep_sst_method = "rsync_wan";
        wsrep_node_address = LT.this.ltnet.IPv4;
        wsrep_node_incoming_address = LT.this.ltnet.IPv4;
        wsrep_node_name = config.networking.hostName;
        wsrep_provider_options = "gmcast.listen_addr=tcp://${LT.this.ltnet.IPv4}:4567";
      };
    };

    ensureUsers = [
      {
        name = "prometheus-mysqld-exporter";
        ensurePermissions = {
          "*.*" = "PROCESS, REPLICATION CLIENT, SELECT, SLAVE MONITOR";
        };
      }
    ];
  };

  systemd.services.mysql = {
    path = [
      config.services.mysql.package
      mysqlenv-common
      mysqlenv-rsync
    ];
    restartIfChanged = false;
    serviceConfig = {
      Restart = lib.mkForce "on-failure";
      TimeoutStartSec = 300;
    };
  };

  systemd.services.prometheus-mysqld-exporter = {
    description = "Prometheus MySQL Exporter";
    wantedBy = [ "multi-user.target" ];
    serviceConfig =
      let
        myCnf = pkgs.writeText "my.cnf" ''
          [client]
          port = 3306
          socket = /run/mysqld/mysqld.sock
          user = prometheus-mysqld-exporter
        '';
      in
      LT.serviceHarden
      // {
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${pkgs.prometheus-mysqld-exporter}/bin/mysqld_exporter --config.my-cnf=${myCnf} --web.listen-address=${LT.this.ltnet.IPv4}:${LT.portStr.Prometheus.MySQLExporter}";

        User = "prometheus-mysqld-exporter";
        Group = "prometheus-mysqld-exporter";
      };
  };

  users.users.prometheus-mysqld-exporter = {
    group = "prometheus-mysqld-exporter";
    isSystemUser = true;
  };
  users.groups.prometheus-mysqld-exporter = { };
}
