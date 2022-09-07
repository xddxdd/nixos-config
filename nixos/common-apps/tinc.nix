{ pkgs, lib, config, ... }:

let
  LT = import ../../helpers {  inherit config pkgs; };

  sanitizeHostname = builtins.replaceStrings [ "-" ] [ "_" ];

  hostToTinc = k: v:
    lib.nameValuePair
      (sanitizeHostname k)
      {
        addresses = [ ]
          ++ lib.optionals (v.public.IPv4 != "") [{ address = v.public.IPv4; }]
          ++ lib.optionals (v.public.IPv6 != "") [{ address = v.public.IPv6; }]
          ++ lib.optionals (v.public.IPv6Alt != "") [{ address = v.public.IPv6Alt; }]
        ;
        rsaPublicKey = lib.mkIf (v.tinc.rsa != "") v.tinc.rsa;
        settings = {
          Compression = 0;
          Ed25519PublicKey = lib.mkIf (v.tinc.ed25519 != "") v.tinc.ed25519;
        };
      };
in
{
  environment.systemPackages = with pkgs; [
    tinc_pre
  ];

  services.tinc.networks = {
    ltmesh = {
      hostSettings = lib.mapAttrs' hostToTinc LT.hosts;
      interfaceType = "tap";
      name = sanitizeHostname config.networking.hostName;
      settings = {
        Broadcast = "direct";
        Interface = "ltmesh";
        Mode = "switch";
        PingInterval = 25;
        PriorityInheritance = true;
        ProcessPriority = lib.mkIf (!config.boot.isContainer) "high";
        ReplayWindow = 128;
      };
    };
  };

  environment.etc = {
    "tinc/ltmesh/tinc-up".source = pkgs.writeShellScript "tinc-up-ltmesh" ''
      ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$INTERFACE.autoconf=0
      ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$INTERFACE.accept_ra=0
      ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.$INTERFACE.addr_gen_mode=1
      ${pkgs.iproute2}/bin/ip addr add fe80::${builtins.toString LT.this.index}/64 dev $INTERFACE
      ${pkgs.iproute2}/bin/ip addr add 169.254.0.${builtins.toString LT.this.index}/24 dev $INTERFACE
      ${pkgs.iproute2}/bin/ip link set $INTERFACE mtu 1280
      ${pkgs.iproute2}/bin/ip link set $INTERFACE up
    '';
    "tinc/ltmesh/tinc-down".source = pkgs.writeShellScript "tinc-down-ltmesh" "";
  };
}
