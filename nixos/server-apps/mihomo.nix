{
  LT,
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
lib.mkIf (LT.this.hasTag LT.tags.cn-accel) {
  sops.secrets.ss-unblock-cn.sopsFile = inputs.secrets + "/common/dae.yaml";

  services.mihomo = {
    enable = true;
    configFile = pkgs.writeText "mihomo.yaml" (
      builtins.toJSON {
        socks-port = LT.port.Mihomo;
        allow-lan = true;
        bind-address = LT.this.ltnet.IPv4;

        mode = "rule";
        log-level = "info";
        ipv6 = false;
        unified-delay = true;
        find-process-mode = "off";

        proxy-providers = {
          cn-subs = {
            type = "file";
            path = "./cn.sub";
          };
        };

        proxy-groups = [
          {
            name = "AUTO";
            type = "url-test";
            use = [ "cn-subs" ];
            url = "http://connect.rom.miui.com/generate_204";
            interval = 300;
            tolerance = 50;
            timeout = 5000;
            expected-status = 204;
            lazy = true;
          }
        ];

        rules = [ "MATCH,AUTO" ];
      }
    );
  };

  systemd.services.mihomo = {
    after = [ "sops-install-secrets.service" ];
    requires = [ "sops-install-secrets.service" ];

    preStart = ''
      install -Dm644 ''${CREDENTIALS_DIRECTORY}/cn.sub /var/lib/private/mihomo/cn.sub
    '';

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5";
      LoadCredential = [
        "cn.sub:${config.sops.secrets.ss-unblock-cn.path}"
      ];
    };
  };
}
