{ lib, ... }:
let
  serviceHardenArgs = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RemoveIPC = true;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = [
      "@system-service"
      # Route-chain and OpenJ9 requires @resources calls
      "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
    ];
  };

  networkToolHardenArgs = serviceHardenArgs // {
    PrivateDevices = false;
    ProtectClock = false;
    ProtectControlGroups = false;
    AmbientCapabilities = [
      "CAP_NET_ADMIN"
      "CAP_NET_BIND_SERVICE"
      "CAP_NET_RAW"
    ];
    CapabilityBoundingSet = [
      "CAP_NET_ADMIN"
      "CAP_NET_BIND_SERVICE"
      "CAP_NET_RAW"
    ];
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];
    SystemCallFilter = [ ];
  };
in
{
  serviceHarden = lib.mapAttrs (k: lib.mkOptionDefault) serviceHardenArgs;
  networkToolHarden = lib.mapAttrs (k: lib.mkOptionDefault) networkToolHardenArgs;
}
