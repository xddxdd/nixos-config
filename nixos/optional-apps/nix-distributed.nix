{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  mkBuildMachine = n: v: let
    isLocal = n == config.networking.hostName;
  in
    assert v.cpuThreads > 0;
      if isLocal
      then null
      else {
        inherit (v) system;
        hostName = "${n}.lantian.pub";
        maxJobs = v.cpuThreads;
        protocol = "ssh-ng";
        speedFactor = v.cpuThreads;
        sshKey = "/home/lantian/.ssh/id_ed25519";
        sshUser = "root";
        supportedFeatures = ["benchmark" "big-parallel"];
      };

  nixBuildNet = {
    hostName = "eu.nixbuild.net";
    systems = ["aarch64-linux"];
    sshKey = "/home/lantian/.ssh/id_ed25519";
    sshUser = "root";
    maxJobs = 100;
    speedFactor = 100;
    supportedFeatures = ["benchmark" "big-parallel"];
  };
in {
  nix = {
    distributedBuilds = true;
    buildMachines =
      [
        # nixBuildNet
      ]
      ++ (lib.filter (v: v != null)
        (lib.mapAttrsToList mkBuildMachine
          (lib.filterAttrs (n: v: builtins.elem LT.tags.nix-builder v.tags) LT.otherHosts)));
  };
}
