{ LT, ... }:
{
  imports = [
    ../../nixos/minimal.nix

    ./ddns.nix
    ./dhcp.nix
    ./firewall.nix
    ./hardware-configuration.nix
    ./networking.nix

    ../../nixos/common-apps/coredns.nix
    ../../nixos/server-components/sidestore-vpn.nix
    ../../nixos/optional-apps/miniupnpd.nix
  ];

  services.miniupnpd = {
    externalInterface = "eth1";
    internalIPs = [
      "eth0"
      "eth0.1"
      "eth0.2"
      # "eth0.5" # IoT devices not allowed UPnP
    ];
  };

  services.suricata = {
    enable = true;
    settings = {
      vars.address-groups.HOME_NET = builtins.concatStringsSep "," (
        LT.constants.reserved.IPv4 ++ LT.constants.reserved.IPv6
      );
      host-mode = "router";
      app-layer.protocols = {
        telnet.enabled = "yes";
        dnp3.enabled = "yes";
        modbus.enabled = "yes";
      };
      outputs = [
        {
          fast = {
            enabled = true;
            filename = "fast.log";
            append = "yes";
          };
        }
        {
          eve-log = {
            enabled = true;
            filetype = "regular";
            filename = "eve.json";
            community-id = true;
            types = [
              {
                alert.tagged-packets = "yes";
              }
            ];
          };
        }
      ];
      af-packet =
        builtins.map
          (i: {
            interface = i;
            cluster-id = "99";
            cluster-type = "cluster_flow";
            defrag = "yes";
          })
          [
            "eth0"
            "eth0.1"
            "eth0.2"
            "eth1"
          ];
    };
  };
}
