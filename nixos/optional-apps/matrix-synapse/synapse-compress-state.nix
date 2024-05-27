{ pkgs, ... }:
{
  imports = [ ../postgresql.nix ];

  systemd.services.synapse-compress-state = {
    after = [ "matrix-synapse.service" ];
    requires = [ "matrix-synapse.service" ];
    script = ''
      exec ${pkgs.matrix-synapse-tools.rust-synapse-compress-state}/bin/synapse_auto_compressor \
        -p "host=/run/postgresql user=matrix-synapse dbname=matrix-synapse" \
        -c 500 \
        -n 100
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "matrix-synapse";
    };
  };

  systemd.timers.synapse-compress-state = {
    wantedBy = [ "timers.target" ];
    partOf = [ "synapse-compress-state.service" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "synapse-compress-state.service";
    };
  };
}
