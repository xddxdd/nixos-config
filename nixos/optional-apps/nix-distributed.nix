{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  mkBuildMachine = n: v:
    let
      isLocal = n == config.networking.hostName;
    in
    assert v.cpuThreads > 0;
    {
      inherit (v) system;
      hostName = v.hostname;
      maxJobs = v.cpuThreads;
      speedFactor = v.cpuThreads;
      supportedFeatures = [ "benchmark" "big-parallel" ];
    } // (if isLocal then {
      hostName = "localhost";
      protocol = null;
    } else {
      protocol = "ssh-ng";
      sshKey = "/home/lantian/.ssh/id_ed25519";
      sshUser = "root";
    });
in
{
  nix = {
    distributedBuilds = true;
    buildMachines = lib.mapAttrsToList mkBuildMachine (LT.hostsWithTag LT.tags.nix-builder);
  };
}
