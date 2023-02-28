{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: {
  age.secrets.waline-env.file = inputs.secrets + "/waline-env.age";

  services.nginx.virtualHosts = {
    "comments.lantian.pub" = {
      listen = LT.nginx.listenHTTPS;
      locations = LT.nginx.addCommonLocationConf {} {
        "/".extraConfig =
          ''
            proxy_pass http://${LT.this.ltnet.IPv4}:${LT.portStr.Waline};
            proxy_set_header REMOTE-HOST $remote_addr;
          ''
          + LT.nginx.locationProxyConf;
        "= /".return = "302 /ui/";
      };
      extraConfig =
        LT.nginx.makeSSL "lantian.pub_ecc"
        + LT.nginx.commonVhostConf true
        + LT.nginx.noIndex true;
    };
  };

  virtualisation.oci-containers.containers = {
    waline = {
      extraOptions = ["--pull" "always"];
      image = "lizheming/waline";
      ports = ["${LT.this.ltnet.IPv4}:${LT.portStr.Waline}:8360"];
      environmentFiles = [config.age.secrets.waline-env.path];
    };
  };
}
