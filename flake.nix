{
  description = "Lan Tian's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-vscode-server = {
      url = "github:iosmanthus/nixos-vscode-server/add-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = github:nix-community/NUR;
    nur-xddxdd = {
      url = github:xddxdd/nur-packages;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hath-nix.url = github:poscat0x04/hath-nix;
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, deploy-rs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts.nix;

      # hostsList = [ "soyoustart" ];
      hostsList = lib.mapAttrsToList (n: v: n) hosts;
    in
    {
      nixosConfigurations = lib.genAttrs hostsList
        (n:
          let
            thisHost = builtins.getAttr n hosts;
          in
          lib.nixosSystem {
            system = if (builtins.hasAttr "system" thisHost) then thisHost.system else "x86_64-linux";
            modules = [
              inputs.agenix.nixosModules.age
              ./common/common.nix
              (import ./common/home-manager.nix { inherit inputs; })
              ({
                networking.hostName = n;
              })
              (./hosts + "/${n}/configuration.nix")
            ];
          });

      deploy = {
        sshUser = "root";
        user = "root";
        autoRollback = false;
        magicRollback = false;

        nodes = lib.genAttrs hostsList
          (n:
            let
              thisHost = builtins.getAttr n hosts;
              system = if (builtins.hasAttr "system" thisHost) then thisHost.system else "x86_64-linux";
              hostname = if (builtins.hasAttr "hostname" thisHost) then thisHost.hostname else "${n}.lantian.pub";
              sshPort = if (builtins.hasAttr "sshPort" thisHost) then thisHost.sshPort else 2222;
            in
            {
              hostname = hostname;
              profiles.system = {
                path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations."${n}";
                sshOpts = [ "-p" (builtins.toString sshPort) ];
              };
            });
      };

      dnsRecords = import ./dns/toplevel.nix rec {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        dns = import ./common/components/dns/default.nix { inherit pkgs; };
      };
    };
}
