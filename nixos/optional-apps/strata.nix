{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
  strata = pkgs.nur-xddxdd.strata;
in
{
  options.lantian.strata = {
    model = lib.mkOption {
      type = lib.types.str;
      default = "IQ3_S";
      description = ''
        Quantization of the qwen-family model to run.
        The default IQ3_S is the qwen family's 3.5-bit GSQ-RCO pick.
      '';
    };
  };

  config = {

    systemd.services.strata = {
      description = "Strata local inference server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      path = [ config.hardware.nvidia.package ];
      environment = {
        HOME = "/var/cache/strata";
        XDG_DATA_HOME = "/var/cache/strata/runtime";
        XDG_CONFIG_HOME = "/var/cache/strata/config";
        CUDA_DEVICE_ORDER = "PCI_BUS_ID";
        CUDA_VISIBLE_DEVICES = "0";
        STRATA_ALLOWED_HOSTS = "strata.${config.networking.hostName}.xuyh0120.win,strata.localhost";
        STRATA_ROUTE_PRIOR = "0"; # https://github.com/Niko1221/Strata/releases/tag/v0.2.7
      };

      preStart = ''
        mkdir -p /var/cache/strata/runtime /var/cache/strata/config /var/cache/strata/data
      '';

      serviceConfig = {
        Type = "simple";
        User = "strata";
        Group = "strata";
        Restart = "always";
        RestartSec = "5s";
        TimeoutStopSec = 60;
        CacheDirectory = "strata";
        WorkingDirectory = "/var/cache/strata";
        PrivateDevices = false;
        MemoryDenyWriteExecute = false;
        LimitMEMLOCK = "infinity";
        # setup.py reads /proc/meminfo to detect available RAM.
        ProcSubset = "all";

        # Model data must stay outside runtime/strata, which is replaced on package updates.
        # The speed projection's refusal-direction control vector is only applied for the
        # qwen/coder families (upstream gate in setup.py), which is why the quant lives in the
        # GSQ-RCO set, not one of the unsloth UD quants. IQ3_S (3.5-bit) is the default; hosts
        # with less RAM (e.g. lt-hp-omen) override it via lantian.strata.model.
        ExecStart = builtins.concatStringsSep " " [
          (lib.getExe strata)
          "--yes"
          "--family qwen"
          "--model ${config.lantian.strata.model}"
          "--backend cuda"
          "--source huggingface"
          "--context 262144"
          "--kv int8"
          "--mtp on"
          "--parallel 1"
          "--vision yes"
          "--experimental-speed-projection on"
          "--no-browser"
          "--host 127.0.0.1"
          "--port ${LT.portStr.Strata}"
          "--gpu 0"
          "--data-dir /var/cache/strata/data"
        ];
      };
    };

    lantian.harden.strata = {
      enable = true;
      cuda = true;
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
  };
}
