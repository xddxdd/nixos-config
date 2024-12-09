{
  LT,
  config,
  inputs,
  ...
}:
{
  age.secrets.waline-env.file = inputs.secrets + "/waline-env.age";

  lantian.nginxVhosts = {
    "comments.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Waline}";
          extraConfig = ''
            proxy_set_header REMOTE-HOST $remote_addr;
          '';
        };
        "= /".return = "307 /ui/";
      };

      sslCertificate = "lantian.pub_ecc";
      noIndex.enable = true;
    };
  };

  virtualisation.oci-containers.containers = {
    waline = {
      extraOptions = [ "--pull=always" ];
      image = "lizheming/waline";
      ports = [ "${LT.this.ltnet.IPv4}:${LT.portStr.Waline}:8360" ];
      environmentFiles = [ config.age.secrets.waline-env.path ];
    };
  };
}
