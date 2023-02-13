{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  nix = {
    extraOptions = ''
      builders-use-substitutes = true
    '';
    distributedBuilds = true;
    buildMachines =
      let
        mkBuildMachine = n:
          let
            isLocal = n == config.networking.hostName;
          in
          {
            inherit (LT.hosts."${n}") system;
            hostName = LT.hosts."${n}".hostname;
            maxJobs = LT.hosts."${n}".cpuThreads;
            speedFactor = LT.hosts."${n}".cpuThreads;
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
      [
        (mkBuildMachine "lt-hp-omen")
        (mkBuildMachine "oracle-vm-arm")
      ];
  };
}
