{
  config,
  pkgs,
  lib,
  LT,
  ...
}:
let
  # The pinned MME parser accepts SGsAP peers under client, not server.
  mmeConfig = pkgs.writeText "mme.yaml" (
    builtins.replaceStrings [ "  sgsap:\n    server:" ] [ "  sgsap:\n    client:" ] (
      builtins.readFile ./config/mme.yaml
    )
  );
  services = [
    "mme"
    "nrf"
    "pcrf"
    "scp"
    "sgwc"
    "sgwu"
    "smf"
    "upf"
  ];
in
{
  systemd.services = builtins.listToAttrs (
    builtins.map (svc: {
      name = "open5gs-${svc}d";
      value = {
        description = "Open5GS ${lib.toUpper svc} Daemon";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "open5gs-certs.service"
        ];
        requires = [
          "network.target"
          "open5gs-certs.service"
        ];
        serviceConfig =
          LT.serviceHarden
          // (
            {
              ExecStart = "${lib.getExe' pkgs.open5gs "open5gs-"}${svc}d -c ${
                if svc == "mme" then mmeConfig else "${./config}/${svc}.yaml"
              }";
              ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID";
              LogsDirectory = "open5gs";
              User = "open5gs";
              Group = "open5gs";
              Restart = "always";
              RestartSec = "5";
              RestartPreventExitStatus = "1";
              IPAddressDeny = "any";
              IPAddressAllow = [
                "localhost"
                "192.168.0.0/24"
                "198.18.110.0/24"
              ];
              # Interface discovery uses getifaddrs(), including for dev: eth0.
              RestrictAddressFamilies = [
                "AF_UNIX"
                "AF_INET"
                "AF_INET6"
                "AF_NETLINK"
              ];
            }
            # freeDiameter configs and extension modules are read from /etc at
            # runtime; bind the real store files into the confinement chroot
            // (lib.optionalAttrs (builtins.pathExists ./freeDiameter/${svc}.conf) {
              BindReadOnlyPaths = [
                "${./freeDiameter}/${svc}.conf:/etc/freeDiameter/${svc}.conf"
                "${config.environment.etc."freeDiameter/lib".source}:/etc/freeDiameter/lib"
                "/var/lib/open5gs-certs/ca.crt"
                "/var/lib/open5gs-certs/${svc}.crt"
                "/var/lib/open5gs-certs/${svc}.key"
              ];
            })
            # TUNSETIFF needs CAP_NET_ADMIN in the host's user namespace.
            // (lib.optionalAttrs (svc == "upf") {
              PrivateDevices = false;
              PrivateUsers = false;
              DevicePolicy = "closed";
              DeviceAllow = [ "/dev/net/tun rw" ];
              BindPaths = [ "/dev/net/tun" ];
              AmbientCapabilities = [ "CAP_NET_ADMIN" ];
              CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
            })
          );
        confinement = {
          enable = true;
          fullUnit = true;
        };
      };
    }) services
  );

  lantian.harden = lib.genAttrs (map (svc: "open5gs-${svc}d") services) (_: true);

  users.users.open5gs = {
    group = "open5gs";
    isSystemUser = true;
  };
  users.groups.open5gs = { };
}
