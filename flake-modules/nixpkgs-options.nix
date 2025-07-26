{
  self,
  inputs,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  LT = import ../helpers {
    inherit lib inputs;
    inherit (inputs) self;
  };
in
{
  perSystem =
    { system, ... }:
    {
      nixpkgs-options =
        let
          permittedInsecurePackages = [
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
            "electron-32.3.3"
            "libsoup-2.74.3"
            "olm-3.2.16"
            "ventoy-1.1.05"
          ];
          overlays = [
            inputs.agenix.overlays.default
            inputs.colmena.overlay
            inputs.nil.overlays.nil
            inputs.nix-alien.overlays.default
            inputs.nix-xilinx.overlay
            inputs.nixd.overlays.default
            inputs.nur-xddxdd.overlays.inSubTree-pinnedNixpkgsWithCuda
            inputs.nur.overlays.default
            inputs.nvfetcher.overlays.default
            inputs.proxmox-nixos.overlays."${system}"
            inputs.secrets.overlays.default
          ] ++ (import ../overlays { inherit inputs; });
        in
        {
          pkgs = {
            sourceInput = inputs.nixpkgs;
            patches = LT.ls ../patches/nixpkgs;
            inherit permittedInsecurePackages overlays;
          };
          pkgs-old-cuda = {
            sourceInput = inputs.nixpkgs;
            patches = LT.ls ../patches/nixpkgs;
            inherit permittedInsecurePackages;
            overlays = overlays ++ [
              (final: prev: { cudaPackages = final.cudaPackages_12_3; })
            ];
          };
          pkgs-stable = {
            sourceInput = inputs.nixpkgs-stable;
            patches = LT.ls ../patches/nixpkgs-stable;
            inherit permittedInsecurePackages overlays;
          };
        };
    };
}
