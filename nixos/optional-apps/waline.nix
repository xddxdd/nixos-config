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

  systemd.services.waline = {
    description = "Waline Comment System";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    requires = ["network-online.target"];

    preStart = ''
      ${pkgs.yarn}/bin/yarn add @waline/vercel

      mkdir -p node_modules/@waline/vercel/src/config
      cat > node_modules/@waline/vercel/src/config/config.production.js <<EOF
      module.exports = {
        host: "${LT.this.ltnet.IPv4}",
        port: ${LT.portStr.Waline},
      };
      EOF
    '';

    serviceConfig =
      LT.serviceHarden
      // {
        EnvironmentFile = config.age.secrets.waline-env.path;
        ExecStart = "${pkgs.nodejs}/bin/node node_modules/@waline/vercel/vanilla.js";

        Restart = "always";
        RestartSec = "3";

        CacheDirectory = "waline";
        WorkingDirectory = "/var/cache/waline";

        User = "waline";
        Group = "waline";
        MemoryDenyWriteExecute = lib.mkForce false;
      };
  };

  users.users.waline = {
    group = "waline";
    isSystemUser = true;
  };
  users.groups.waline = {};
}
