{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
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
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          hostName = "localhost";
          maxJobs = 4;
          speedFactor = 4;
          supportedFeatures = [ "benchmark" "big-parallel" ];
        };
        mkBuildMachine = n: {
          inherit (LT.hosts."${n}") system;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          hostName = LT.hosts."${n}".hostname;
          maxJobs = 4;
          speedFactor = 4;
          supportedFeatures = [ "benchmark" "big-parallel" ];
        };
        nixBuildNet = {
          hostName = "eu.nixbuild.net";
          systems = [ "x86_64-linux" "aarch64-linux" ];
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          maxJobs = 100;
          speedFactor = 100;
          supportedFeatures = [ "benchmark" "big-parallel" ];
        };
      in
      [
        # localhost
        (mkBuildMachine "oracle-vm-arm")
        # (mkBuildMachine "soyoustart")
        # nixBuildNet
      ];
  };
}
