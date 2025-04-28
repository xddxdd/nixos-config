{ config, ... }:
let
  containerOptions = {
    extraOptions = [
      "--pull=always"
      "--net=host"
    ];
    image = "ghcr.io/nickvsnetworking/pyhss/pyhss";
    volumes = [
      "${./pyhss.yaml}:/pyhss/config.yaml:ro"
      "/var/lib/pyhss:/var/lib/pyhss"
      # "/run/redis-pyhss:/run/redis-pyhss"
    ];
  };
in
{
  virtualisation.oci-containers.containers = {
    pyhss-hss = containerOptions // {
      entrypoint = "python";
      cmd = [ "hssService.py" ];
    };
    pyhss-diameter = containerOptions // {
      entrypoint = "python";
      cmd = [ "diameterService.py" ];
    };
    pyhss-api = containerOptions // {
      entrypoint = "bash";
      cmd = [
        "-c"
        "sed -i 's/0.0.0.0/127.0.0.47/g' apiService.py && python apiService.py"
      ];
    };
  };

  services.redis.servers.pyhss = {
    enable = true;
    port = 16379;
    databases = 1;
    unixSocketPerm = 666;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/pyhss 755 root root"
  ];

  systemd.services = {
    podman-pyhss-hss = {
      requires = [ "redis-pyhss.service" ];
      after = [ "redis-pyhss.service" ];
    };
    podman-pyhss-diameter = {
      requires = [ "redis-pyhss.service" ];
      after = [ "redis-pyhss.service" ];
    };
    podman-pyhss-api = {
      requires = [ "redis-pyhss.service" ];
      after = [ "redis-pyhss.service" ];
    };
  };

  lantian.nginxVhosts = {
    "pyhss.${config.networking.hostName}.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.47:8080";
        };
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "pyhss.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.47:8080";
        };
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
