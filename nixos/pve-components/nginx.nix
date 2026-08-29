{
  lib,
  config,
  LT,
  ...
}:
{
  imports = [
    ../common-apps/nginx/nginx.nix
    ../common-apps/nginx/vhost-options
    ../common-apps/nginx/vhosts-default.nix
  ];

  config = lib.mkIf config.services.proxmox-ve.enable {
    lantian.nginxVhosts."${config.networking.hostName}.xuyh0120.win" = {
      serverAliases = [ config.services.proxmox-ve.ipAddress ];
      sslCertificate = "zerossl-xuyh0120.win";
      accessibleBy = "private";
      noIndex.enable = true;
      locations."/" = {
        proxyPass = "https://127.0.0.1:${LT.portStr.Proxmox}";
        proxyWebsockets = true;
        proxyNoTimeout = true;
      };
    };
  };
}
