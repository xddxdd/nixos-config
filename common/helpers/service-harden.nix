{ config, pkgs, ... }:

pkgs.lib.mapAttrs (k: v: pkgs.lib.mkOptionDefault v) {
  AmbientCapabilities = "";
  CapabilityBoundingSet = "";
  DynamicUser = true;
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
  RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
  RestrictNamespaces = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
  SystemCallArchitectures = "native";
  SystemCallErrorNumber = "EPERM";
  SystemCallFilter = [
    "@system-service"
    "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @resources @swap"
  ];
}
