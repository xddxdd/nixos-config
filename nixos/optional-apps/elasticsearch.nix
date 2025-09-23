{
  LT,
  pkgs,
  config,
  ...
}:
{
  services.elasticsearch = {
    enable = true;
    port = LT.port.ElasticSearch;
    plugins = with pkgs.elasticsearchPlugins; [
      analysis-smartcn
    ];
  };

  lantian.nginxVhosts."es.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.ElasticSearch}";
        enableBasicAuth = true;
      };
    };
    accessibleBy = "private";
    sslCertificate = "zerossl-${config.networking.hostName}.xuyh0120.win";
    noIndex.enable = true;
  };
}
