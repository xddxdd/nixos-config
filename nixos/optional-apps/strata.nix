{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
  # CUDA manifests reference their original backend, so a scope override still forces its assertions.
  strataPkgs = import pkgs.path {
    localSystem = pkgs.stdenv.hostPlatform;
    inherit (pkgs) overlays;
    config = pkgs.config // {
      cudaCapabilities = lib.filter (cap: cap != "6.1") pkgs.config.cudaCapabilities;
    };
  };
  strata = strataPkgs.nur-xddxdd.strata;
in
{
  systemd.services.strata = {
    description = "Strata local inference server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    wants = [ "network.target" ];

    path = [ config.hardware.nvidia.package ];
    environment = {
      HOME = "/var/lib/strata";
      XDG_DATA_HOME = "/var/lib/strata/runtime";
      XDG_CONFIG_HOME = "/var/lib/strata/config";
      CUDA_DEVICE_ORDER = "PCI_BUS_ID";
      CUDA_VISIBLE_DEVICES = "0";
      STRATA_ALLOWED_HOSTS = "strata.${config.networking.hostName}.xuyh0120.win,strata.localhost";
    };

    # The package wrapper copies into runtime/strata but does not create its parent.
    preStart = ''
      mkdir -p /var/lib/strata/runtime /var/lib/strata/config /var/lib/strata/data
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      User = "strata";
      Group = "strata";
      Restart = "always";
      RestartSec = "5s";
      TimeoutStopSec = 60;
      StateDirectory = "strata";
      WorkingDirectory = "/var/lib/strata";
      PrivateDevices = false;
      MemoryDenyWriteExecute = false;
      LimitMEMLOCK = "infinity";
      # setup.py reads /proc/meminfo to detect available RAM.
      ProcSubset = "all";

      # Model data must stay outside runtime/strata, which is replaced on package updates.
      # Explicit --model/--family would force setup on every restart.
      ExecStart = "${lib.getExe strata} --yes --vision no --no-browser --host 127.0.0.1 --port ${LT.portStr.Strata} --gpu 0 --data-dir /var/lib/strata/data";
    };
  };

  users.users.strata = {
    group = "strata";
    isSystemUser = true;
  };
  users.groups.strata = { };

  lantian.localVhosts.strata = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.Strata}";
      proxyNoTimeout = true;
      proxyWebsockets = true;
      # The shared proxy preserves Host and Origin, so browser controls are same-origin.
      # Upstream trusted_origins is a run-config key, not an environment variable.
    };
  };
}
