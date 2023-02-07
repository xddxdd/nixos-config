{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  nix = {
    extraOptions = ''
      builders-use-substitutes = true
    '';
    distributedBuilds = true;
    buildMachines =
      let
        localhost = {
          inherit (config.nixpkgs) system;
          hostName = "localhost";
          maxJobs = 4;
          protocol = null;
          speedFactor = 4;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          supportedFeatures = [ "benchmark" "big-parallel" ];
        };
        mkBuildMachine = n: {
          inherit (LT.hosts."${n}") system;
          hostName = LT.hosts."${n}".hostname;
          maxJobs = 4;
          protocol = "ssh-ng";
          speedFactor = 4;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          supportedFeatures = [ "benchmark" "big-parallel" ];
        };
        nixBuildNet = {
          hostName = "eu.nixbuild.net";
          maxJobs = 100;
          protocol = "ssh-ng";
          speedFactor = 100;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          supportedFeatures = [ "benchmark" "big-parallel" ];
          systems = [ "x86_64-linux" "aarch64-linux" ];
        };
      in
      [
        localhost
        (mkBuildMachine "oracle-vm-arm")
        # (mkBuildMachine "oneprovider")
        # nixBuildNet
      ];
  };
}
