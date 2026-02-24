{
  lib,
  LT,
  config,
  ...
}:
let
  mkBuildMachine =
    n: v:
    let
      isLocal = n == config.networking.hostName;
    in
    assert v.cpuThreads > 0;
    if isLocal then
      [ ]
    else
      [
        {
          inherit (v) system;
          hostName = "${n}.lantian.pub";
          maxJobs = v.cpuThreads;
          protocol = "ssh-ng";
          speedFactor = v.cpuThreads;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          supportedFeatures = [ ];
          mandatoryFeatures = [ ];
        }
      ]
      ++ lib.optionals (v.cpuThreads >= 8) [
        {
          inherit (v) system;
          hostName = "${n}.lantian.pub";
          maxJobs = 1;
          protocol = "ssh-ng";
          speedFactor = v.cpuThreads;
          sshKey = "/home/lantian/.ssh/id_ed25519";
          sshUser = "root";
          supportedFeatures = [ "big-parallel" ];
          mandatoryFeatures = [ "big-parallel" ];
        }
      ];

  nixBuildNet = {
    hostName = "eu.nixbuild.net";
    systems = [ "aarch64-linux" ];
    sshKey = "/home/lantian/.ssh/id_ed25519";
    sshUser = "root";
    maxJobs = 100;
    speedFactor = 100;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
    ];
  };
in
{
  nix = {
    distributedBuilds = true;
    buildMachines =
      lib.flatten (
        lib.filter (v: v != null) (
          lib.mapAttrsToList mkBuildMachine (
            lib.filterAttrs (n: v: v.hasTag LT.tags.nix-builder) LT.otherHosts
          )
        )
      )
      ++ [ nixBuildNet ];
  };
}
