{
  config,
  lib,
  pkgs,
  LT,
  ...
}:
let
  strata = pkgs.nur-xddxdd.strata;
  podman = lib.getExe pkgs.podman;

  # Model definitions and their rendered commands are the
  # lantian.llama-swap.models option (nixos/minimal-modules/llama-swap-models.nix),
  # shared with the pi client config, which derives its model list from the same
  # entries. A null _cmd means this host lacks the VRAM the model needs.
  models = config.lantian.llama-swap.models;
  served = lib.filterAttrs (_: m: m._cmd != null) models;

  # The model servers run as children of llama-swap, so they share its paths
  # and its view of the driver.
  modelRuntimePackages = [
    config.hardware.nvidia.package
    pkgs.bash
    pkgs.coreutils
  ];
  modelBinPath = lib.makeBinPath modelRuntimePackages;

  kindEnv = {
    maya = {
      HOME = "/var/cache/project-maya";
      XDG_DATA_HOME = "/var/cache/project-maya/data";
      XDG_CONFIG_HOME = "/var/cache/project-maya/config";
      PATH = modelBinPath;
    };
    sglang = {
      CONTAINER_HOST = "unix:///run/podman/podman.sock";
      HOME = "/var/cache/llama-swap";
    };
    strata = {
      HOME = "/var/cache/strata";
      XDG_DATA_HOME = "/var/cache/strata/runtime";
      XDG_CONFIG_HOME = "/var/cache/strata/config";
      CUDA_DEVICE_ORDER = "PCI_BUS_ID";
      # Any *.localhost name passes the rebinding check by itself
      STRATA_ALLOWED_HOSTS = "llama-swap.${config.networking.hostName}.xuyh0120.win";
      # From https://www.reddit.com/r/LocalLLaMA/s/ZGY93Mx2t3
      STRATA_HC_Q8 = "1";
      STRATA_KVA = "0";
      STRATA_PREFILL_CPU_SHARE = "0";
      STRATA_ROUTE_PRIOR = "0"; # https://github.com/Niko1221/Strata/releases/tag/v0.2.7
      STRATA_ROUTE_TAIL_SKIP = "0";
      PATH = modelBinPath;
    };
  };

  provisioned = lib.filterAttrs (_: m: m._provision != null) served;

  # One download per host, before the model is first served: the servers keep
  # 80-120 GB of weights outside the store, and maya refuses to start on a
  # config it has not written yet. The guard makes the unit a no-op once the
  # model's config exists, and re-arms it if the data folder is wiped.
  provisionUnits = lib.mapAttrs' (
    id: m:
    lib.nameValuePair "llama-swap-provision-${id}" {
      description = "Provision ${m.name} for llama-swap";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      before = [ "llama-swap.service" ];
      unitConfig.ConditionPathExistsGlob = m._provisionGuard;
      # NixOS gives every unit a default PATH, so the driver comes in as path
      environment = removeAttrs kindEnv.${m.kind} [ "PATH" ];
      path = modelRuntimePackages;
      serviceConfig = {
        Type = "oneshot";
        User = "llama-swap";
        Group = "llama-swap";
        ExecStart = m._provision;
      };
    }
  ) provisioned;

  entries = lib.mapAttrs (
    _: m:
    {
      inherit (m) name;
      cmd = m._cmd;
    }
    // lib.optionalAttrs (m.kind == "sglang") {
      # Podman is driven over the rootful socket: the container itself runs
      # outside this sandbox, so the paths in its command above are host paths.
      cmdStop = "${podman} --remote stop \${MODEL_ID}";
      unloadTimeout = 120;
      # The share client's worker sends bursts of parallel requests and drops the
      # websocket on any non-2xx reply, so keep headroom above the default 10.
      concurrencyLimit = 32;
    }
    // lib.optionalAttrs (builtins.hasAttr m.kind kindEnv) {
      env = lib.mapAttrsToList (name: value: "${name}=${value}") kindEnv.${m.kind};
    }
  ) served;
in
{
  imports = [
    ../llama-cpp.nix
    ./module.nix
  ];

  config = {
    assertions = [
      {
        assertion = LT.this.vramGB > 0;
        message = "llama-swap requires vramGB > 0";
      }
      {
        assertion =
          builtins.length (builtins.attrNames entries)
          <= LT.port.LlamaSwapInference.End - LT.port.LlamaSwapInference.Start + 1;
        message = "llama-swap model count exceeds the allocated inference port range";
      }
    ];

    # Stratas' model data must stay outside runtime/strata, which is replaced on
    # package updates. Speed projection is off: upstream makes its control vector
    # for the original model, not for Swift 1.5. Maya hydrates its application
    # files into data/project-maya the same way; its configs and the downloaded
    # model live beside them. Both model servers run as children of llama-swap, so
    # the cache belongs to its service user.
    systemd.tmpfiles.settings = {
      llama-swap = {
        "/var/cache/strata"."d" = {
          mode = "0755";
          user = "llama-swap";
          group = "llama-swap";
        };
        "/var/cache/strata"."Z" = {
          user = "llama-swap";
          group = "llama-swap";
        };
        "/var/cache/huggingface"."d" = {
          mode = "0755";
          user = "root";
          group = "root";
        };
        "/var/cache/project-maya"."d" = {
          mode = "0755";
          user = "llama-swap";
          group = "llama-swap";
        };
        "/var/cache/torchinductor"."d" = {
          mode = "0755";
          user = "root";
          group = "root";
        };
      };
    };

    services.llama-swap = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = LT.port.LlamaSwap;

      settings = {
        startPort = LT.port.LlamaSwapInference.Start;
        globalTTL = 3600;
        healthCheckTimeout = 3600;
        models = entries;
        routing.router.settings.groups.single = {
          swap = true;
          exclusive = true;
          members = builtins.attrNames entries;
        };
      };
    };

    systemd.services = provisionUnits // {
      llama-swap = {
        serviceConfig = {
          User = "llama-swap";
          Group = "llama-swap";
          DynamicUser = lib.mkForce false;
          AmbientCapabilities = lib.mkForce [ ];
          CapabilityBoundingSet = lib.mkForce [ ];
          ProcSubset = "all";
          # Model servers are spawned inside the confinement chroot.
          BindPaths = [
            "-/var/cache/project-maya"
            "-/var/cache/strata"
          ];
        };

        confinement.packages = [
          podman
        ]
        # strata only runs where its model is served
        ++ lib.optional (lib.any (m: m.kind == "strata") (builtins.attrValues served)) strata
        # maya too
        ++ lib.optional (lib.any (m: m.kind == "maya") (
          builtins.attrValues served
        )) pkgs.nur-xddxdd.project-maya;
      };
    };

    lantian.port-audit.knownViolations = [
      "${LT.portStr.LlamaSwapInference.Start}-${LT.portStr.LlamaSwapInference.End}"
    ];

    lantian.harden.llama-swap = {
      enable = true;
      cuda = true;
      secret = true; # rootful podman socket
    };

    users.users.llama-swap = {
      group = "llama-swap";
      # rootful podman socket for the sglang container
      extraGroups = lib.optional config.virtualisation.podman.enable "podman";
      isSystemUser = true;
    };
    users.groups.llama-swap = { };

    lantian.localVhosts."llama-swap" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.LlamaSwap}";
        proxyNoTimeout = true;
      };
    };
  };
}
