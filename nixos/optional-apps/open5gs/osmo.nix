{
  lib,
  pkgs,
  LT,
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

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe pkgs.osmo-hlr} -c ${./osmo-hlr.cfg}";
      StateDirectory = "osmo-hlr";
      WorkingDirectory = "/var/lib/osmo-hlr";
      DynamicUser = true;
      # Join the host-created network namespace, not a private user namespace.
      PrivateUsers = false;
      IPAddressDeny = "any";
      IPAddressAllow = [
        "localhost"
        "192.168.0.0/24"
        "198.18.110.0/24"
        LT.this.ltnet.IPv4
      ];

      Restart = "always";
      RestartSec = "5";
    };
  };
  systemd.services.osmo-msc = config.lantian.netns.osmo-msc.bind {
    description = "Osmo-MSC";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = LT.serviceHarden // {
      ExecStart = "${lib.getExe pkgs.osmo-msc} -c ${./osmo-msc.cfg}";
      StateDirectory = "osmo-msc";
      WorkingDirectory = "/var/lib/osmo-msc";
      DynamicUser = true;
      PrivateUsers = false;
      IPAddressDeny = "any";
      IPAddressAllow = [
        "localhost"
        "192.168.0.0/24"
        "198.18.110.0/24"
        LT.this.ltnet.IPv4
      ];

      Restart = "always";
      RestartSec = "5";
    };
  };

  lantian.harden.osmo-hlr = true;
  lantian.harden.osmo-msc = true;
}
