{
  LT,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./mcp-servers.nix ];

  virtualisation.oci-containers.containers.mcpo = {
    ports = [
      "127.0.0.1:${LT.portStr.Mcpo}:${LT.portStr.Mcpo}"
    ];
    cmd = [
      "--port=${LT.portStr.Mcpo}"
      "--config=/config.json"
    ];
    image = "ghcr.io/open-webui/mcpo:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    volumes = [ "/run/mcpo/config.json:/config.json" ];
  };

  systemd.services.podman-mcpo = {
    path = with pkgs; [ curl ];
    preStart = lib.mkBefore ''
      ${config.lantian.mcp.toJSON "/run/mcpo/config.json"}
    '';
    postStart = ''
      curl \
        --fail \
        --retry 100 \
        --retry-delay 5 \
        --retry-max-time 300 \
        --retry-all-errors \
        http://127.0.0.1:${LT.portStr.Mcpo}/openapi.json
    '';
    serviceConfig.RuntimeDirectory = "mcpo";
  };

  lantian.nginxVhosts."mcpo.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Mcpo}";
        proxyNoTimeout = true;
        extraConfig = ''
          sub_filter_types *;
          sub_filter_once off;
          sub_filter 'http://0.0.0.0:${LT.portStr.Mcpo}' 'https://mcpo.${config.networking.hostName}.xuyh0120.win';
        '';
      };
    };

    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
