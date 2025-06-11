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
    { system, pkgs-stable, ... }:
    {
      nixpkgs-options =
        let
          proxmox-overlay =
            _final: prev:
            import "${self.packages."${system}".proxmox-nixos-patched}/pkgs" {
              pkgs-unstable = prev;
              pkgs = pkgs-stable;
            };

          permittedInsecurePackages = [
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
            "electron-32.3.3"
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
            inputs.secrets.overlays.default
            proxmox-overlay
          ] ++ (import ../overlays { inherit inputs; });
        in
        {
          pkgs = {
            sourceInput = inputs.nixpkgs;
            patches = LT.ls ../patches/nixpkgs;
            inherit permittedInsecurePackages overlays;
          };
          pkgs-stable = {
            sourceInput = inputs.nixpkgs-stable;
            patches = LT.ls ../patches/nixpkgs-stable;
            inherit permittedInsecurePackages overlays;
          };
          proxmox-nixos = {
            sourceInput = inputs.proxmox-nixos;
            patches = LT.ls ../patches/proxmox-nixos;
          };
        };
    };
}
