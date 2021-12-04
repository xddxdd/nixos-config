{ config, pkgs, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  nginxHelper = import ../helpers/nginx.nix { inherit config pkgs; };
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
        "${thisHost.ltnet.IPv4}:13080:80"
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
        "/var/cache/ci:/cache"
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
        "${thisHost.ltnet.IPv4}:13081:80"
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
        "/var/cache/ci:/cache"
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
        "${thisHost.ltnet.IPv4}:13082:3000"
      ];
    };
    dind = {
      image = "docker:dind";
      cmd = [ "--data-root" "/var/lib/docker-dind" ];
      volumes = [
        "/var/cache/ci:/cache"
        "/var/lib:/var/lib"
        "/run/docker-dind:/run"
      ];
      extraOptions = [ "--privileged" ];
    };
  };

  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
      name = "docker-dind";
      version = "0.0.1";

      phases = [ "installPhase" ];
      buildInputs = [ pkgs.makeWrapper ];
      installPhase = ''
        makeWrapper "${pkgs.docker}/bin/docker" "$out/bin/docker-dind" --set DOCKER_HOST "unix:///run/docker-dind/docker.sock"
      '';
    })
  ];

  systemd.tmpfiles.rules = [
    "d /var/cache/ci 755 root root"
    "d /var/lib/docker-dind 755 root root"
    "d /run/docker-dind 755 root root"
  ];

  services.nginx.virtualHosts = {
    "ci.lantian.pub" = {
      listen = nginxHelper.listen443;
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4}:13080";
          extraConfig = nginxHelper.locationProxyConf;
        };
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
    "ci-github.lantian.pub" = {
      listen = nginxHelper.listen443;
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4}:13081";
          extraConfig = nginxHelper.locationProxyConf;
        };
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
    "vault.lantian.pub" = {
      listen = nginxHelper.listen443;
      locations = nginxHelper.addCommonLocationConf {
        "/" = {
          proxyPass = "http://${thisHost.ltnet.IPv4}:8200";
          extraConfig = nginxHelper.locationProxyConf;
        };
      };
      extraConfig = nginxHelper.makeSSL "lantian.pub_ecc"
        + nginxHelper.commonVhostConf true;
    };
  };
}
