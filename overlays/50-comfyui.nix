_: final: prev:
let
  # cuDNN 9.11 dropped pre-Turing GPUs; keep this correction local to ComfyUI.
  # https://github.com/pytorch/pytorch/blob/v2.15.0/torch/backends/cudnn/__init__.py
  cudaPackages = final.cudaPackages_12.overrideScope (
    _: super: {
      manifests = super.manifests // {
        cudnn = {
          release_label = "9.10.2";
          cudnn = {
            name = "NVIDIA CUDA Deep Neural Network library";
            license = "cudnn";
            license_path = "cudnn/LICENSE.txt";
            version = "9.10.2.21";
            cuda_variant = [ "12" ];
            # https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_9.10.2.json
            linux-x86_64.cuda12 = {
              relative_path = "cudnn/linux-x86_64/cudnn-linux-x86_64-9.10.2.21_cuda12-archive.tar.xz";
              sha256 = "d0defcbc4c6dad711ff4cb66d254036a300c9071b07c7b64199aacab534313c1";
            };
            linux-aarch64.cuda12 = {
              relative_path = "cudnn/linux-aarch64/cudnn-linux-aarch64-9.10.2.21_cuda12-archive.tar.xz";
              sha256 = "1bb3df3c05480832b0498e317996b54ea8a48a3b6ec5f8c734d02302093d43d9";
            };
            linux-sbsa.cuda12 = {
              relative_path = "cudnn/linux-sbsa/cudnn-linux-sbsa-9.10.2.21_cuda12-archive.tar.xz";
              sha256 = "4d57dceba3be27a68b078ce8630525bf40ab7f1b546eb45d0b363c3eeb55f8fa";
            };
          };
        };
      };
    }
  );
in
{
  comfyui-pascal =
    assert final.lib.assertMsg (
      final.config.cudaCapabilities == [ "6.1" ]
    ) "comfyui-pascal requires the cuda-pascal package set";
    (prev.comfyui.override {
      inherit cudaPackages;
      python3 = prev.python3.override {
        packageOverrides = _: pythonPrev: {
          torch = pythonPrev.torch.override {
            cudaSupport = true;
            inherit cudaPackages;
            gpuTargets = [ "6.1" ];
            useSystemNccl = false;
            withNvshmem = false;
            withCusparselt = false;
            withCufile = false;
          };
          # Keep GPU inference in PyTorch; only omit comfy-kitchen's newer-GPU kernels.
          # Its pure-PyTorch eager backend supports the unquantized image workflows.
          # https://github.com/Comfy-Org/comfy-kitchen/tree/v0.2.41#installation
          comfy-kitchen = pythonPrev.comfy-kitchen.override { cudaSupport = false; };
        };
      };
    }).overrideAttrs
      (old: {
        # nixpkgs gates ComfyUI on CUDA 13; the optional CUDA kernels are omitted above.
        # https://github.com/NixOS/nixpkgs/blob/2786a2a72088ecf32aea5b3ec52099e6a7cff78f/pkgs/by-name/co/comfyui/package.nix
        meta = old.meta // {
          broken = false;
        };
      });
}
