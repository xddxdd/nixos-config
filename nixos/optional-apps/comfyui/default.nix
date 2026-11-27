{
  config,
  lib,
  pkgs,
  inputs,
  LT,
  ...
}:
let
  models = import (inputs.secrets + "/comfyui-models.nix");
in
{
  sops.secrets.comfyui-huggingface-header =
    lib.mkIf (lib.any (model: model.authenticated or false) (lib.attrValues models))
      {
        sopsFile = LT.secret "comfyui.yaml";
      };

  services.comfyui = {
    enable = true;
    package = pkgs.comfyui-pascal;
    listen = [ "127.0.0.1" ];
    port = LT.port.ComfyUI;
    extraArgs = [
      # Pascal lacks native BF16 and tensor cores; store BF16 weights but execute FP32.
      "--force-fp32"
      "--fp32-text-enc"
      "--fp32-vae"
      "--use-split-cross-attention"
      "--disable-dynamic-vram"
      "--disable-comfy-compiler"
      "--disable-triton-backend"
      "--disable-all-custom-nodes"
      "--disable-partner-nodes"
    ];
  };

  systemd.services =
    lib.mapAttrs' (
      name: model:
      lib.nameValuePair "comfyui-provision-${name}" {
        description = "Provision ComfyUI ${name} weights";
        requiredBy = [ "comfyui.service" ];
        before = [ "comfyui.service" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        unitConfig.ConditionPathExists = "!/var/lib/comfyui/models/${model.path}";
        path = [
          pkgs.coreutils
          pkgs.curl
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "comfyui";
          Group = "comfyui";
          StateDirectory = "comfyui";
          StateDirectoryMode = "0700";
          TimeoutStartSec = "infinity";
          UMask = "0077";
          LoadCredential = lib.optionals (model.authenticated or false) [
            "huggingface-header:${config.sops.secrets.comfyui-huggingface-header.path}"
          ];
        };
        script = ''
          file=/var/lib/comfyui/models/${model.path}
          mkdir -p "$(dirname "$file")"
          curl --fail --location --retry 5 --continue-at - \
            ${
              lib.optionalString (model.authenticated or false
              ) ''--header "@$CREDENTIALS_DIRECTORY/huggingface-header"''
            } \
            --output "$file.part" \
            '${model.url}'
          if ! printf '%s  %s\n' '${model.sha256}' "$file.part" | sha256sum --check -; then
            rm -f "$file.part"
            exit 1
          fi
          mv "$file.part" "$file"
        '';
      }
    ) models
    // {
      comfyui = {
        # New provisioning dependencies need a restart of the already-running service.
        restartTriggers = [ (builtins.toJSON models) ];
        environment = {
          HOME = "/var/lib/comfyui";
          XDG_CACHE_HOME = "/var/cache/comfyui";
          LD_LIBRARY_PATH = "/run/opengl-driver/lib";
          CUDA_DEVICE_ORDER = "PCI_BUS_ID";
        };
        serviceConfig = {
          CacheDirectory = "comfyui";
          MemoryDenyWriteExecute = false;
        };
      };
    };

  lantian.harden.comfyui = {
    enable = true;
    cuda = true;
  };

  lantian.localVhosts.comfyui.locations."/" = {
    proxyPass = "http://127.0.0.1:${LT.portStr.ComfyUI}";
    proxyWebsockets = true;
    proxyNoTimeout = true;
  };
}
