{
  LT,
  config,
  inputs,
  pkgs,
  ...
}:
{
  services.open-webui = {
    enable = true;
    package = inputs.nixpkgs-stable.legacyPackages."${pkgs.system}".open-webui;
    port = LT.port.OpenWebUI;
    environment = {
      ENV = "prod";
      OLLAMA_API_BASE_URL = "https://ollama.lt-home-vm.xuyh0120.win";
      WEBUI_AUTH = "False";
      WEBUI_URL = "https://open-webui.${config.networking.hostName}.xuyh0120.win";
    };
  };

  lantian.nginxVhosts = {
    "open-webui.${config.networking.hostName}.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenWebUI}";
      };

      sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
      noIndex.enable = true;
    };
    "open-webui.localhost" = {
      listenHTTP.enable = true;
      listenHTTPS.enable = false;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OpenWebUI}";
      };

      noIndex.enable = true;
      accessibleBy = "localhost";
    };
  };
}
