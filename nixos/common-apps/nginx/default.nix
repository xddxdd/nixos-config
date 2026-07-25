{ ... }:
{
  imports = [
    # keep-sorted start
    ./autoconfig.nix
    ./hosts.nix
    ./libravatar.nix
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./testssl.nix
    ./vhost-hydra-proxy.nix
    ./vhost-lab.nix
    ./vhost-matrix-element
    ./vhost-options
    ./vhost-tools
    ./vhost-um
    ./vhosts.nix
    ./whois-server.nix
    # keep-sorted end
  ];
}
