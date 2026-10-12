{
  LT,
  ...
}:
{
  virtualisation.oci-containers.containers.cliproxyapi = {
    labels."io.containers.autoupdate" = "registry";
    image = "docker.io/eceasy/cli-proxy-api:latest";
    ports = [ "127.0.0.1:${LT.portStr.CLIProxyAPI}:8317" ];
    volumes = [
      "/var/lib/cliproxyapi/config.yaml:/CLIProxyAPI/config.yaml"
      "/var/lib/cliproxyapi/auth:/root/.cli-proxy-api"
      "/var/lib/cliproxyapi/plugins:/CLIProxyAPI/plugins"
    ];
  };

  systemd.tmpfiles.settings.cliproxyapi = {
    "/var/lib/cliproxyapi"."d" = {
      mode = "700";
      user = "root";
      group = "root";
    };
    "/var/lib/cliproxyapi/auth"."d" = {
      mode = "700";
      user = "root";
      group = "root";
    };
    "/var/lib/cliproxyapi/plugins"."d" = {
      mode = "700";
      user = "root";
      group = "root";
    };
  };

  lantian.localVhosts.cliproxyapi = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
        proxyNoTimeout = true;
        proxyOverrideHost = "localhost";
      };
      "= /".return = "302 /management.html";
    };
  };

  lantian.nginxVhosts = {
    "ai-api.xuyh0120.win" = {
      locations = {
        "/".return = "404";
        "/v1/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
        "/backend-api/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
      };

      sslCertificate = "zerossl-xuyh0120.win";
      noIndex.enable = true;
    };
    "cliproxyapi.xuyh0120.win" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:${LT.portStr.CLIProxyAPI}";
          proxyNoTimeout = true;
          proxyOverrideHost = "localhost";
        };
        "= /".return = "302 /management.html";
      };

      accessibleBy = "private";
      sslCertificate = "zerossl-xuyh0120.win";
      noIndex.enable = true;
    };
  };
}
