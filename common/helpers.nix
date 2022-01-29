{ config, pkgs, ... }:

rec {
  hosts = import ../hosts.nix;
  this = builtins.getAttr config.networking.hostName hosts;
  otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

  containerIP = import helpers/container-ip.nix;
  dnssecKeys = import helpers/dnssec-keys.nix;
  port = import helpers/port.nix;
  portStr = pkgs.lib.mapAttrsRecursive (k: v: builtins.toString v) port;

  _importArgs = { inherit config pkgs hosts this otherHosts containerIP dnssecKeys port portStr; };

  container = import helpers/container.nix _importArgs;
  nginx = import helpers/nginx.nix _importArgs;
  serviceHarden = import helpers/service-harden.nix _importArgs;
  zshrc = import helpers/zshrc.nix _importArgs;
}
