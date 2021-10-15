{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  imports = [
    ./docker.nix
    ./vault.nix
  ];

  age.secrets.drone-ci-env.file = ../../secrets/drone-ci-env.age;
  age.secrets.drone-ci-github-env.file = ../../secrets/drone-ci-github-env.age;
  age.secrets.drone-ci-vault-env.file = ../../secrets/drone-ci-vault-env.age;

  virtualisation.oci-containers.containers = {
    drone = {
      image = "drone/drone:2";
      environmentFiles = [ config.age.secrets.drone-ci-env.path ];
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13080:80"
      ];
      volumes = [
        "/var/lib/drone:/data"
      ];
    };
    drone-runner = {
      image = "drone/drone-runner-docker:1";
      environmentFiles = [ config.age.secrets.drone-ci-env.path ];
      volumes = [
        "/run/docker-dind:/run"
        "/cache:/cache"
      ];
      dependsOn = [
        "drone"
        "drone-vault"
      ];
    };
    drone-github = {
      image = "drone/drone:2";
      environmentFiles = [ config.age.secrets.drone-ci-github-env.path ];
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13081:80"
      ];
      volumes = [
        "/var/lib/drone-github:/data"
      ];
    };
    drone-runner-github = {
      image = "drone/drone-runner-docker:1";
      environmentFiles = [ config.age.secrets.drone-ci-github-env.path ];
      volumes = [
        "/run/docker-dind:/run"
        "/cache:/cache"
      ];
      dependsOn = [
        "drone-github"
        "drone-vault"
      ];
    };
    drone-vault = {
      image = "drone/vault";
      environmentFiles = [ config.age.secrets.drone-ci-vault-env.path ];
      ports = [
        "${thisHost.ltnet.IPv4Prefix}.1:13082:3000"
      ];
    };
    dind = {
      image = "docker:dind";
      cmd = [ "--data-root" "/var/lib/docker-dind" ];
      volumes = [
        "/cache:/cache"
        "/srv:/srv"
        "/var/lib:/var/lib"
        "/run/docker-dind:/run"
      ];
      extraOptions = [ "--privileged" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /cache 755 root root"
    "d /var/lib/docker-dind 755 root root"
    "d /run/docker-dind 755 root root"
  ];
}
