{
  config,
  inputs,
  lib,
  LT,
  pkgs,
  ...
}:
let
  oidc-tester-app = pkgs.nur-xddxdd.oidc-tester-app.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ../../patches/oidc-tester-accept-plain-strings.patch
    ];
  });
in
{
  sops.secrets.oidc-tester-dex-secret = {
    sopsFile = inputs.secrets + "/common/dex.yaml";
    key = "dex-oidc-tester-secret";
    owner = "oidc-tester";
    group = "oidc-tester";
  };

  systemd.services.oidc-tester = {
    description = "OIDC Tester App";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${lib.getExe oidc-tester-app} \
        --host 127.0.0.1 \
        --port ${LT.portStr.OidcTester} \
        --public-url https://oidc-tester.lantian.pub/ \
        --id oidc-tester \
        --issuer https://login.lantian.pub \
        --secret "$(cat ${config.sops.secrets.oidc-tester-dex-secret.path})"
    '';

    serviceConfig = LT.serviceHarden // {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      User = "oidc-tester";
      Group = "oidc-tester";
    };
  };

  users.users.oidc-tester = {
    group = "oidc-tester";
    isSystemUser = true;
  };
  users.groups.oidc-tester = { };

  lantian.nginxVhosts."oidc-tester.lantian.pub" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.OidcTester}";
      };
    };

    # Conflict with oidc-tester paths
    enableCommonLocationOptions = false;

    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
