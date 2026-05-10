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
            "electron-36.9.5"
            "electron-38.8.4"
            "jitsi-meet-1.0.8792"
            "libsoup-2.74.3"
            "mbedtls-2.28.10"
            "olm-3.2.16"
            "ventoy-1.1.12"
            # keep-sorted end
          ];
          overlays = [
            # keep-sorted start
            inputs.angrr.overlays.default
            inputs.chinese-fonts-overlay.overlays.default
            inputs.colmena.overlay
            inputs.comfyui-nix.overlays.default
            inputs.firefox-addons.overlays.default
            inputs.llm-agents.overlays.default
            inputs.nix-alien.overlays.default
            inputs.nix-cache-proxy.overlays.default
            inputs.nur-xddxdd.overlays.inSubTree-pinnedNixpkgs
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
          pkgsWithCuda = {
            sourceInput = inputs.nixpkgs;
            patches = LT.ls ../patches/nixpkgs;
            inherit permittedInsecurePackages overlays;
            settings = settings // {
              cudaSupport = true;
            };
          };
        };
    };
}
