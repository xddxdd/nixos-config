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
      env = [
        "CONTAINER_HOST=unix:///run/podman/podman.sock"
        "HOME=/var/cache/llama-swap"
      ];
    }
    // lib.optionalAttrs (m.kind == "strata") {
      env = [
        "HOME=/var/cache/strata"
        "XDG_DATA_HOME=/var/cache/strata/runtime"
        "XDG_CONFIG_HOME=/var/cache/strata/config"
        "CUDA_DEVICE_ORDER=PCI_BUS_ID"
        "CUDA_VISIBLE_DEVICES=0"
        # Any *.localhost name passes the rebinding check by itself
        "STRATA_ALLOWED_HOSTS=llama-swap.${config.networking.hostName}.xuyh0120.win"
        "STRATA_ROUTE_PRIOR=0" # https://github.com/Niko1221/Strata/releases/tag/v0.2.7
        "PATH=${
          lib.makeBinPath [
            config.hardware.nvidia.package
            pkgs.bash
            pkgs.coreutils
          ]
        }"
      ];
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
    # package updates. The speed projection's refusal-direction control vector is
    # only applied for the qwen/coder families (upstream gate in setup.py), which
    # is why the quant lives in the GSQ-RCO set, not one of the unsloth UD quants.
    # Both model servers now run as children of llama-swap, so the cache belongs
    # to its service user.
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

    systemd.services.llama-swap = {
      serviceConfig = {
        User = "llama-swap";
        Group = "llama-swap";
        DynamicUser = lib.mkForce false;
        AmbientCapabilities = lib.mkForce [ ];
        CapabilityBoundingSet = lib.mkForce [ ];
        ProcSubset = "all";
        # Model servers are spawned inside the confinement chroot.
        BindPaths = [ "-/var/cache/strata" ];
      };

      confinement.packages = [
        podman
      ]
      # strata only runs where its model is served
      ++ lib.optional (models ? strata && models.strata._cmd != null) strata;
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
      extraGroups = [ "podman" ]; # rootful podman socket for the sglang container
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
