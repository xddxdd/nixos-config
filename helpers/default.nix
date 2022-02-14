{ config, pkgs, ... }:

rec {
  hosts = import ../hosts.nix;
  this = builtins.getAttr config.networking.hostName hosts;
  otherHosts = builtins.removeAttrs hosts [ config.networking.hostName ];

  containerIP = import ./container-ip.nix;
  dnssecKeys = import ./dnssec-keys.nix;
  port = import ./port.nix;
  portStr = pkgs.lib.mapAttrsRecursive (k: v: builtins.toString v) port;
  serviceHarden = import ./service-harden.nix _importArgs;

  _importArgs = { inherit config pkgs hosts this otherHosts containerIP dnssecKeys port portStr serviceHarden; };

  container = import ./container.nix _importArgs;
  netns = import ./netns.nix _importArgs;
  nginx = import ./nginx.nix _importArgs;
  yggdrasil = import ./yggdrasil _importArgs;
  zshrc = import ./zshrc.nix _importArgs;
}
