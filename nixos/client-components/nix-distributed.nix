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
        mkBuildMachine = n: {
          inherit (LT.hosts."${n}") system;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          hostName = LT.hosts."${n}".hostname;
        };
        nixBuildNet = {
          hostName = "eu.nixbuild.net";
          system = "x86_64-linux";
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          maxJobs = 100;
          supportedFeatures = [ "benchmark" "big-parallel" ];
        };
      in
      [
        (mkBuildMachine "oracle-vm-arm")
        (mkBuildMachine "soyoustart")
        nixBuildNet
      ];
  };
}
