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
            # keep-sorted start
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
            "electron-32.3.3"
            "libsoup-2.74.3"
            "olm-3.2.16"
            "ventoy-1.1.07"
            # keep-sorted end
          ];
          overlays = [
            # keep-sorted start
            inputs.agenix.overlays.default
            inputs.angrr.overlays.default
            inputs.colmena.overlay
            inputs.firefox-addons.overlays.default
            inputs.nil.overlays.nil
            inputs.nix-alien.overlays.default
            inputs.nix-xilinx.overlay
            inputs.nixd.overlays.default
            inputs.nur-xddxdd.overlays.inSubTree-pinnedNixpkgsWithCuda
            inputs.nur.overlays.default
            inputs.proxmox-nixos.overlays."${system}"
            inputs.secrets.overlays.default
            # keep-sorted end
          ]
          ++ (import ../overlays { inherit inputs; });
          settings = {
            android_sdk.accept_license = true;
          };
        in
        {
          pkgs = {
            sourceInput = inputs.nixpkgs;
            patches = LT.ls ../patches/nixpkgs;
            inherit permittedInsecurePackages overlays settings;
          };
        };
    };
}
