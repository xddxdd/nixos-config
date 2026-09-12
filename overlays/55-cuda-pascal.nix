# Current nixpkgs pins cudnn 9.22.0 and tensorrt 10.16.1 in every cudaPackages
# set, but cuDNN 9.12 dropped all pre-Turing GPUs (compute capability < 7.5) and
# TensorRT 10.0 dropped all pre-Volta GPUs (compute capability < 7.0), making
# both unusable on Pascal (CC 6.1). Pin them at the last releases supporting
# Pascal: cuDNN 9.11.1 (CUDA 12 builds only) and TensorRT 8.6.1 (cuda-12.0
# build, works with any CUDA 12.x runtime).
#
# Each redist package resolves its source from the `manifests` attribute of its
# cudaPackages scope (buildRedist inherits `manifests` from the scope's fixed
# point), so overriding the scope's manifest entries re-pins a component
# without touching any other component. The TensorRT 8.6.1 archive, however, is
# only served from developer.nvidia.com under .../tensorrt/secure/... — the
# developer.download.nvidia.com host used by mkRedistUrl 403s it — so buildRedist
# must also be rebuilt against an _cuda with a redirected mkRedistUrl. (Overriding
# the top-level pkgs._cuda would not be enough: all-packages.nix threads its own
# _cuda into the cudaPackages construction.)
#
# CUDA 13 dropped Pascal, so cudaPackages must stay on CUDA 12 regardless of
# which version future nixpkgs picks as the default: pin every cudaPackages_12_*
# set and point the cudaPackages / cudaPackages_12 aliases at the newest one.
_: final: prev:
let
  inherit (prev) lib;

  # Mirrored from:
  # https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_9.11.1.json
  cudnn911 = {
    release_label = "9.11.1";
    cudnn = {
      name = "NVIDIA CUDA Deep Neural Network library";
      license = "cudnn";
      license_path = "cudnn/LICENSE.txt";
      version = "9.11.1.4";
      cuda_variant = [ "12" ];
      linux-x86_64.cuda12 = {
        relative_path = "cudnn/linux-x86_64/cudnn-linux-x86_64-9.11.1.4_cuda12-archive.tar.xz";
        sha256 = "609ac48a448e4533287a4d7c62056bf130fae8c3b1eb2a218080e29e0026ec18";
      };
      linux-aarch64.cuda12 = {
        relative_path = "cudnn/linux-aarch64/cudnn-linux-aarch64-9.11.1.4_cuda12-archive.tar.xz";
        sha256 = "e45dbae19bf4909619d6012bb2bbeffd020ed9d09c35af44546375cbb8d067fa";
      };
      linux-sbsa.cuda12 = {
        relative_path = "cudnn/linux-sbsa/cudnn-linux-sbsa-9.11.1.4_cuda12-archive.tar.xz";
        sha256 = "e7a65ea73f65ee9ec9cc73bfaa5441d06a1116f62943d01b8dad02f4b51b177c";
      };
    };
  };

  # Hand-made following nixpkgs' _cuda/manifests/tensorrt/README.md (NVIDIA has
  # no redistrib manifest for pre-10.0 releases), from:
  # https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/secure/8.6.1/tars/TensorRT-8.6.1.6.Linux.x86_64-gnu.cuda-12.0.tar.gz
  tensorrt861 = {
    release_label = "8.6.1";
    tensorrt = {
      name = "NVIDIA TensorRT";
      license = "TensorRT";
      version = "8.6.1.6";
      cuda_variant = [ "12" ];
      linux-x86_64.cuda12 = {
        relative_path = "tensorrt/secure/8.6.1/tars/TensorRT-8.6.1.6.Linux.x86_64-gnu.cuda-12.0.tar.gz";
        sha256 = "0f8157a5fc5329943b338b893591373350afa90ca81239cdadd7580cd1eba254";
      };
    };
  };

  _cuda = prev._cuda.extend (
    _: super: {
      lib = super.lib // {
        mkRedistUrl =
          redistName: relativePath:
          if redistName == "tensorrt" && lib.hasPrefix "tensorrt/secure/" relativePath then
            "https://developer.nvidia.com/downloads/compute/machine-learning/" + relativePath
          else
            super.lib.mkRedistUrl redistName relativePath;
      };
    }
  );

  pinScope =
    cudaPackages:
    cudaPackages.overrideScope (
      self: super: {
        manifests = super.manifests // {
          cudnn = cudnn911;
          tensorrt = tensorrt861;
        };
        buildRedist = import (prev.path + "/pkgs/development/cuda-modules/buildRedist") {
          inherit _cuda;
          inherit (final)
            lib
            autoAddDriverRunpath
            autoPatchelfHook
            fetchurl
            srcOnly
            stdenv
            stdenvNoCC
            zstd
            ;
          inherit (super)
            autoAddCudaCompatRunpath
            backendStdenv
            cudaMajorMinorVersion
            cudaMajorVersion
            cudaNamePrefix
            markForCudatoolkitRootHook
            removeStubsFromRunpathHook
            ;
          inherit (self) manifests;
        };
      }
    );

  cuda12Sets = lib.filterAttrs (name: _: builtins.match "cudaPackages_12_[0-9]+" name != null) prev;

  latestCuda12 =
    let
      minorOf = name: lib.toInt (lib.last (lib.splitString "_" name));
    in
    builtins.head (builtins.sort (a: b: minorOf a > minorOf b) (builtins.attrNames cuda12Sets));
in
(lib.mapAttrs (_: pinScope) cuda12Sets)
// {
  cudaPackages_12 = final.${latestCuda12};
  cudaPackages = lib.recurseIntoAttrs final.${latestCuda12};
}
