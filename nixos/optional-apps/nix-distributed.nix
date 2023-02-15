{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  mkBuildMachine = n: v:
    let
      isLocal = n == config.networking.hostName;
    in
    assert v.cpuThreads > 0;
    if isLocal then null else {
      inherit (v) system;
      hostName = "${n}.lantian.pub";
      maxJobs = v.cpuThreads;
      protocol = "ssh-ng";
      speedFactor = v.cpuThreads;
      sshKey = "/home/lantian/.ssh/id_ed25519";
      sshUser = "root";
      supportedFeatures = [ "benchmark" "big-parallel" ];
    };
in
{
  nix = {
    distributedBuilds = true;
    buildMachines = lib.filter (v: v != null) (lib.mapAttrsToList mkBuildMachine (LT.hostsWithTag LT.tags.nix-builder));
  };
}
