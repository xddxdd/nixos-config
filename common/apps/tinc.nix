{ pkgs, config, ... }:

let
  hosts = import ../../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

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

  environment.etc = {
    "tinc/ltmesh/tinc-up".source = pkgs.writeScript "tinc-up-ltmesh" ''
      #!${pkgs.stdenv.shell}
      ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$INTERFACE.autoconf=0
      ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$INTERFACE.accept_ra=0
      ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$INTERFACE.addr_gen_mode=1
      ${pkgs.iproute2}/bin/ip addr add fe80::${builtins.toString thisHost.index}/64 dev $INTERFACE
      ${pkgs.iproute2}/bin/ip addr add 169.254.0.${builtins.toString thisHost.index}/24 dev $INTERFACE
      ${pkgs.iproute2}/bin/ip link set $INTERFACE mtu 1280
      ${pkgs.iproute2}/bin/ip link set $INTERFACE up
    '';
    "tinc/ltmesh/tinc-down".source = pkgs.writeScript "tinc-down-ltmesh" ''
      #!${pkgs.stdenv.shell}
    '';
  };
}
