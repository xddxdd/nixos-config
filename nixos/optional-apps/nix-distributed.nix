{
  lib,
  LT,
  config,
  pkgs,
  ...
}:
let
  cfg = config.lantian.nix-distributed;

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
          sshKey = cfg.sshKeyPath;
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
          sshKey = cfg.sshKeyPath;
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
    sshKey = cfg.sshKeyPath;
    sshUser = "root";
    maxJobs = 100;
    speedFactor = 100;
    supportedFeatures = [
      "benchmark"
      "big-parallel"
    ];
  };

  platforms = builtins.concatStringsSep "," (
    lib.uniqueStrings (config.nix.settings.extra-platforms ++ [ pkgs.stdenv.hostPlatform.system ])
  );
in
{
  options.lantian.nix-distributed.sshKeyPath = lib.mkOption {
    type = lib.types.str;
    default = "/home/lantian/.ssh/id_ed25519";
  };

  config = {
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

    # FIXME: hydra might be unable to handle duplicate entries
    environment.etc."nix/machines-with-localhost".text = config.environment.etc."nix/machines".text + ''
      localhost ${platforms} - 4 1 kvm,nixos-test,big-parallel,benchmark - -
    '';

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nix-remote-build-off" ''
        sudo rm -f /etc/nix/machines
      '')
      (pkgs.writeShellScriptBin "nix-remote-build-on" ''
        sudo ln -s ${config.environment.etc."nix/machines".source} /etc/nix/machines
      '')
    ];
  };
}
