{
  pkgs,
  lib,
  config,
  ...
}:
{
  lantian.netns.osmo-hlr.ipSuffix = "32";
  lantian.netns.osmo-msc.ipSuffix = "31";

  systemd.services.osmo-hlr = config.lantian.netns.osmo-hlr.bind {
    description = "Osmo-HLR";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.osmo-hlr} -c ${./osmo-hlr.cfg}";
      StateDirectory = "osmo-hlr";
      WorkingDirectory = "/var/lib/osmo-hlr";

      Restart = "always";
      RestartSec = "5";
    };
  };
  systemd.services.osmo-msc = config.lantian.netns.osmo-msc.bind {
    description = "Osmo-MSC";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.osmo-msc} -c ${./osmo-msc.cfg}";
      StateDirectory = "osmo-msc";
      WorkingDirectory = "/var/lib/osmo-msc";

      Restart = "always";
      RestartSec = "5";
    };
  };
}
