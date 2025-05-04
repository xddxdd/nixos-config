{
  config,
  pkgs,
  LT,
  ...
}:
{
  boot.kernelModules = [ "xt_RTPENGINE" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.xt_rtpengine ];

  systemd.services.rtpengine = {
    description = "NGCP RTP/media Proxy Daemon";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${pkgs.nur-xddxdd.rtpengine}/bin/rtpengine \
        -f \
        -E \
        --interface=192.168.0.9 \
        --no-log-timestamps \
        --pidfile /run/rtpengine/ngcp-rtpengine-daemon.pid \
        --config-file ${./rtpengine.conf}
    '';

    serviceConfig = LT.serviceHarden // {
      RuntimeDirectory = "rtpengine";
      CacheDirectory = "rtpengine";
      PIDFile = "/run/rtpengine/ngcp-rtpengine-daemon.pid";
      User = "rtpengine";
      Group = "rtpengine";
      LimitNOFILE = 150000;

      PrivateMounts = false;
      ProcSubset = "all";
      AmbientCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_SYS_NICE"
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_SYS_NICE"
      ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];
      SystemCallFilter = [ "@system-service" ];

      Restart = "always";
      RestartSec = "5";
    };
  };

  users.users.rtpengine = {
    group = "rtpengine";
    isSystemUser = true;
  };
  users.groups.rtpengine = { };
}
