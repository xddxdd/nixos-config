{
  lib,
  LT,
  config,
  pkgs,
  inputs,
  ...
}:
let
  mkBuildMachine =
    n: v:
    let
      isLocal = n == config.networking.hostName;
      gccarchFeatures =
        lib.optionals (v.system == "x86_64-linux") [ "gccarch-x86-64" ]
        ++ lib.optionals (v.x86ArchLevel != null && v.x86ArchLevel >= 2) [ "gccarch-x86-64-v2" ]
        ++ lib.optionals (v.x86ArchLevel != null && v.x86ArchLevel >= 3) [ "gccarch-x86-64-v3" ]
        ++ lib.optionals (v.x86ArchLevel != null && v.x86ArchLevel >= 4) [ "gccarch-x86-64-v4" ];
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
          # Use legacy protocol for Hydra
          protocol = "ssh";
          speedFactor = v.cpuThreads;
          sshKey = config.sops.secrets.nix-ssh-privkey.path;
          sshUser = "nix-builder";
          supportedFeatures = gccarchFeatures;
          mandatoryFeatures = [ ];
        }
      ]
      ++ lib.optionals (v.cpuThreads >= 8) [
        {
          inherit (v) system;
          hostName = "${n}.lantian.pub";
          maxJobs = 1;
          # Use legacy protocol for Hydra
          protocol = "ssh";
          speedFactor = v.cpuThreads;
          sshKey = config.sops.secrets.nix-ssh-privkey.path;
          sshUser = "nix-builder";
          supportedFeatures = [ "big-parallel" ] ++ gccarchFeatures;
          mandatoryFeatures = [ "big-parallel" ];
        }
      ];

  nixBuildNet = {
    hostName = "eu.nixbuild.net";
    systems = [
      "armv7l-linux"
      "aarch64-linux"
    ];
    sshKey = config.sops.secrets.nix-ssh-privkey.path;
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
  sops.secrets.nix-ssh-privkey.sopsFile = inputs.secrets + "/nix-client.yaml";

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

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nix-remote-build-off" ''
      sudo rm -f /etc/nix/machines
    '')
    (pkgs.writeShellScriptBin "nix-remote-build-on" ''
      sudo ln -s ${config.environment.etc."nix/machines".source} /etc/nix/machines
    '')
  ];
}
