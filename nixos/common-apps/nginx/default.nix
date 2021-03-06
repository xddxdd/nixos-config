{ config, pkgs, lib, ... }:

{
  imports = [
    ./libravatar.nix
    ./nginx.nix
    ./oauth2-proxy.nix
    ./proxy.nix
    ./testssl.nix
    ./vhosts.nix
    ./whois-server.nix
  ];
}
