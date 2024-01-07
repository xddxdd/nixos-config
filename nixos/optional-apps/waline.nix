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

  lantian.nginxVhosts = {
    "comments.lantian.pub" = {
      locations = {
        "/" = {
          proxyPass = "http://${LT.this.ltnet.IPv4}:${LT.portStr.Waline}";
          extraConfig = ''
            proxy_set_header REMOTE-HOST $remote_addr;
          '';
        };
        "= /".return = "302 /ui/";
      };

      sslCertificate = "lantian.pub_ecc";
      noIndex.enable = true;
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
