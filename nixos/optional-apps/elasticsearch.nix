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
