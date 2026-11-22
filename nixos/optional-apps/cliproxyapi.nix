{
  pkgs,
  lib,
  LT,
  ...
}:
let
  # Patched cli-proxy-api (numtide/llm-agents.nix):
  # A provider prefix makes the prefixed ID the only registered model name, so
  # bare upstream names are never listed or routed. Two providers therefore
  # cannot share one registry entry when a provider's model name happens to
  # equal another provider's prefix plus model name.
  # doCheck is off because upstream tests assert that bare names stay registered.
  cli-proxy-api = pkgs.llm-agents.cli-proxy-api.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/cliproxyapi-prefix-only-models.patch
    ];
    doCheck = false;
    doInstallCheck = false;
  });

  # astrlink-guard weights for cpa-reductant, pinned to the revision the plugin
  # verifies them against (guard.PinnedFiles).
  guardBase = "https://huggingface.co/QuantumNous/astrlink-guard/resolve/7216b6a3b897ef903d4b1ba367ae6fb95b0fa5e4/int8";
  cpa-reductant-model = pkgs.linkFarm "cpa-reductant-model" [
    {
      name = "model_int8.onnx";
      path = pkgs.fetchurl {
        url = "${guardBase}/model_int8.onnx";
        hash = "sha256-CgcNMRNhXjO6O4TWvUhvZjo3fATEsFbnOBcyF59Rgyo=";
      };
    }
    {
      name = "model_int8.onnx_data";
      path = pkgs.fetchurl {
        url = "${guardBase}/model_int8.onnx_data";
        hash = "sha256-C6NCFs7q0B4K4t/Y5G1Stn567oCwT3Itm3WGE6kcAGc=";
      };
    }
    {
      name = "tokenizer.json";
      path = pkgs.fetchurl {
        url = "${guardBase}/tokenizer.json";
        hash = "sha256-DPOyNe8SVlgBWmyAJqX+bygIi/glEBqZDsGKECAP7vQ=";
      };
    }
  ];
in
{
  systemd.services.cliproxyapi = {
    description = "CLIProxyAPI";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = lib.getExe cli-proxy-api;
      Restart = "always";
      RestartSec = "3";

      StateDirectory = "cliproxyapi";
      WorkingDirectory = "/var/lib/cliproxyapi";

      User = "cliproxyapi";
      Group = "cliproxyapi";
    };

    environment.CPA_REDUCTANT_MODEL_DIR = "${cpa-reductant-model}";
  };
  lantian.harden.cliproxyapi.enable = true;

  users.users.cliproxyapi = {
    group = "cliproxyapi";
    isSystemUser = true;
  };
  users.groups.cliproxyapi.members = [ "nginx" ];

  lantian.nginxVhosts = {
    "ai-api.xuyh0120.win" = {
      locations = {
        "/".return = "404";
        "/v1/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
      };

      accessibleBy = "public";
      sslCertificate = "lets-encrypt-xuyh0120.win";
      noIndex.enable = true;
    };
    "cliproxyapi.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
        "= /".return = "302 /management.html";
      };

      accessibleBy = "private";
      sslCertificate = "lets-encrypt-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
