{ ... }:
{
  imports = [
    ./api.nix
    ./autoconfig.nix
    ./libravatar.nix
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./testssl.nix
    ./vhost-matrix-element
    ./vhost-options
    ./vhost-tools
    ./vhosts.nix
    ./whois-server.nix
  ];
}
