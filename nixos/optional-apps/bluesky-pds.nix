{
  config,
  LT,
  ...
}:
{
  sops.secrets.bluesky-pds-jwt-secret.sopsFile = LT.secret "bluesky-pds.yaml";
  sops.secrets.bluesky-pds-admin-password.sopsFile = LT.secret "bluesky-pds.yaml";
  sops.secrets.bluesky-pds-plc-rotation-key.sopsFile = LT.secret "bluesky-pds.yaml";
  sops.secrets.bluesky-pds-smtp-url.sopsFile = LT.secret "bluesky-pds.yaml";
  sops.templates.bluesky-pds-env.content = ''
    PDS_JWT_SECRET=${config.sops.placeholder.bluesky-pds-jwt-secret}
    PDS_ADMIN_PASSWORD=${config.sops.placeholder.bluesky-pds-admin-password}
    PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=${config.sops.placeholder.bluesky-pds-plc-rotation-key}
    PDS_EMAIL_SMTP_URL=${config.sops.placeholder.bluesky-pds-smtp-url}
  '';

  services.bluesky-pds = {
    enable = true;
    pdsadmin.enable = true;

    environmentFiles = [ config.sops.templates.bluesky-pds-env.path ];

    settings = {
      PDS_HOSTNAME = "at.lantian.pub";
      PDS_PORT = LT.port.BlueskyPDS;
      PDS_ACCEPTING_REPO_IMPORTS = "true";
      PDS_EMAIL_FROM_ADDRESS = config.programs.msmtp.accounts.default.from;
    };
  };

  systemd.services.bluesky-pds.serviceConfig.RestartSec = "5s";

  lantian.harden.bluesky-pds = {
    enable = true;
    secret = true;
  };

  lantian.nginxVhosts."at.lantian.pub" = {
    serverAliases = [ "*.at.lantian.pub" ];

    locations."/" = {
      proxyPass = "http://127.0.0.1:${LT.portStr.BlueskyPDS}";
      proxyNoTimeout = true;
    };

    sslCertificate = "lets-encrypt-at.lantian.pub";
    noIndex.enable = true;
  };
}
