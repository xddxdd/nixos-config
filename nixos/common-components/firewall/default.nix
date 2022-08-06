{ config, pkgs, lib, ... }@args:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  # Cannot use NixOS's services.nftables, it requires disable iptables
  # and will conflict with docker
  nftRules = pkgs.callPackage ./nft-rules.nix args;

  iptablesRules = pkgs.callPackage ./iptables-rules.nix args;
in
{
  systemd.services.nftables = {
    enable = !LT.this.openvz;
    description = "Nftables rules";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nftables}/bin/nft -f ${nftRules}";
    };
  };

  systemd.services.iptables = {
    enable = LT.this.openvz;
    description = "Iptables rules";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = {
      Type = "oneshot";
    };
    path = [ pkgs.iptables-legacy ];
    script = iptablesRules;
  };
}