{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.lantian = {
    imports = [
      ./home-lantian.nix
      inputs.nixos-vscode-server.nixosModules.homeManager
    ];
    services.auto-fix-vscode-server.enable = true;
  };

  nixpkgs.overlays = [
    inputs.nur.overlay
    (final: prev: {
      nur = import inputs.nur {
        nurpkgs = prev;
        pkgs = prev;
        repoOverrides = { xddxdd = import inputs.nur-xddxdd { pkgs = prev; }; };
      };
    })
  ];
}
