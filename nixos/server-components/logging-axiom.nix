{
  pkgs,
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.axiom-syslog-proxy-env.file = inputs.secrets + "/axiom-syslog-proxy-env.age";

  systemd.services.axiom-syslog-proxy = {
    description = "Axiom Syslog Proxy";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${pkgs.axiom-syslog-proxy}/bin/axiom-syslog-proxy --addr-tcp 127.0.0.1:601 --addr-udp 127.0.0.1:514";
      EnvironmentFile = config.age.secrets.axiom-syslog-proxy-env.path;

      Restart = "on-failure";
      RestartSec = "5";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      User = "axiom";
      Group = "axiom";

      StandardOutput = "null";
      StandardError = "null";
    };
  };

  users.users.axiom = {
    group = "axiom";
    isSystemUser = true;
  };
  users.groups.axiom = { };

  services.rsyslogd = {
    enable = true;
    defaultConfig = ''
      module(load="imjournal")
      # Do not enable or exceeds Axiom field limit
      # module(load="mmjsonparse")
      *.* action(type="omfwd" target="127.0.0.1" port="514" protocol="udp")
    '';
  };
}
