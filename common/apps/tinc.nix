# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;

  sanitizeHostname = builtins.replaceStrings [ "-" ] [ "_" ];

  hostToTinc = hostname: { public
                         , tincPub
                         , ...
                         }:
    pkgs.lib.nameValuePair
      (sanitizeHostname hostname)
      ({
        addresses = [ ]
          ++ pkgs.lib.optionals (builtins.hasAttr "IPv4" public) [{ address = public.IPv4; }]
          ++ pkgs.lib.optionals (builtins.hasAttr "IPv6" public) [{ address = public.IPv6; }];
        rsaPublicKey = tincPub;
        settings = {
          Compression = 1;
          IndirectData = true;
        };
      });
in
{
  environment.systemPackages = with pkgs; [
    tinc_pre
  ];

  services.tinc.networks = {
    ltmesh = {
      hostSettings = pkgs.lib.mapAttrs' hostToTinc hosts;
      interfaceType = "tap";
      name = sanitizeHostname config.networking.hostName;
      settings = {
        Interface = "ltmesh";
        Mode = "switch";
        Broadcast = "direct";
        DirectOnly = true;
        PriorityInheritance = true;
        ProcessPriority = "high";
        ReplayWindow = 128;
      };
    };
  };
}
