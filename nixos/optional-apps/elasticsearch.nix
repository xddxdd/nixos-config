{
  LT,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.secrets}/nixos-hidden-module/bd998f7ec298455a"
  ];

  services.elasticsearch = {
    enable = true;
    port = LT.port.ElasticSearch;
    plugins = with pkgs.elasticsearchPlugins; [
      analysis-smartcn
    ];
    extraConf = ''
      xpack.security.enabled: false
    '';
    logging = ''
      logger.action.name = org.elasticsearch.action
      logger.action.level = error

      appender.console.type = Console
      appender.console.name = console
      appender.console.layout.type = PatternLayout
      appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

      rootLogger.level = error
      rootLogger.appenderRef.console.ref = console
    '';
  };

  lantian.localVhosts.es = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.ElasticSearch}";
        enableBasicAuth = true;
      };
    };
  };
}
