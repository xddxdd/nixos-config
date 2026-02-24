{
  lib,
  LT,
  pkgs,
  ...
}:
let
  package = pkgs.callPackage ./package.nix { inherit (LT) sources; };
in
lib.mkIf (LT.this.hasTag LT.tags.nix-builder) {
  systemd.services.nix-ubw = {
    description = "Nix - Unlimited Build Works";
    wantedBy = [ "multi-user.target" ];
    bindsTo = [ "nix-daemon.service" ];

    environment = {
      RUST_LOG = "warn";
    };

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      ExecStart = lib.getExe package;
      Restart = "always";
      RestartSec = "3";

      AmbientCapabilities = [ "CAP_SYS_PTRACE" ];
      CapabilityBoundingSet = [ "CAP_SYS_PTRACE" ];
      Nice = "-20";
      ProcSubset = "all";
      ProtectProc = "ptraceable";
      SystemCallFilter = [ ];
    };
  };
}
