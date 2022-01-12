{ pkgs, config, ... }:

let
  LT = import ../helpers.nix {  inherit config pkgs; };

  sanitizeHostname = builtins.replaceStrings [ "-" ] [ "_" ];

  hostToTinc = k: v:
    pkgs.lib.nameValuePair
      (sanitizeHostname k)
      ({
        addresses = [ ]
          ++ pkgs.lib.optionals (pkgs.lib.hasAttrByPath [ "public" "IPv4" ] v) [{ address = v.public.IPv4; }]
          ++ pkgs.lib.optionals (pkgs.lib.hasAttrByPath [ "public" "IPv6" ] v) [{ address = v.public.IPv6; }]
          ++ pkgs.lib.optionals (pkgs.lib.hasAttrByPath [ "public" "IPv6Alt" ] v) [{ address = v.public.IPv6Alt; }]
        ;
        rsaPublicKey = pkgs.lib.mkIf (pkgs.lib.hasAttrByPath [ "tinc" "rsa" ] v) v.tinc.rsa;
        settings = {
          Compression = 0;
          Ed25519PublicKey = pkgs.lib.mkIf (pkgs.lib.hasAttrByPath [ "tinc" "ed25519" ] v) v.tinc.ed25519;
        };
      });
in
{
  environment.systemPackages = with pkgs; [
    tinc_pre
  ];

  services.tinc.networks = {
    ltmesh = {
      hostSettings = pkgs.lib.mapAttrs' hostToTinc LT.hosts;
      interfaceType = "tap";
      name = sanitizeHostname config.networking.hostName;
      settings = {
        Interface = "ltmesh";
        Mode = "switch";
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
      ${pkgs.iproute2}/bin/ip addr add fe80::${builtins.toString LT.this.index}/64 dev $INTERFACE
      ${pkgs.iproute2}/bin/ip addr add 169.254.0.${builtins.toString LT.this.index}/24 dev $INTERFACE
      ${pkgs.iproute2}/bin/ip link set $INTERFACE mtu 1280
      ${pkgs.iproute2}/bin/ip link set $INTERFACE up
    '';
    "tinc/ltmesh/tinc-down".source = pkgs.writeScript "tinc-down-ltmesh" ''
      #!${pkgs.stdenv.shell}
    '';
  };
}
