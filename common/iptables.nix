{ config, pkgs, modules, ... }:

let
  hosts = import ../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;

  # Cannot use NixOS's services.nftables, it requires disable iptables
  # and will conflict with docker
  nftRules = pkgs.writeText "nft.conf" ''
    #${pkgs.nftables}/bin/nft -f
    table inet lantian
    delete table inet lantian

    table inet lantian {
      chain FILTER_INPUT {
        type filter hook input priority 5; policy accept;

        # Drop timestamp ICMP pkts
        meta l4proto icmp icmp type timestamp-reply drop
        meta l4proto icmp icmp type timestamp-request drop

        # Block non-DN42 traffic in DN42
        iifname "dn42*" jump DN42_INPUT
      }

      chain FILTER_FORWARD {
        type filter hook forward priority 5; policy accept;

        # DN42 firewall rules
        iifname "dn42*" oifname "eth*" reject
        iifname "dn42*" oifname "henet" reject

        # Block non-DN42 traffic in DN42
        iifname "dn42*" jump DN42_INPUT
        oifname "dn42*" jump DN42_OUTPUT
      }

      chain FILTER_OUTPUT {
        type filter hook output priority 5; policy accept;
        oifname "dn42*" jump DN42_OUTPUT
      }

      chain NAT_PREROUTING {
        type nat hook prerouting priority -95; policy accept;

        # wg-lantian
        ${pkgs.lib.optionalString (pkgs.lib.hasAttrByPath [ "public" "IPv4" ] thisHost) ''
          ip daddr ${thisHost.public.IPv4} tcp dport { 51820 } dnat to 192.0.2.2
          ip daddr ${thisHost.public.IPv4} udp dport { 51820 } dnat to 192.0.2.2
          ip daddr ${thisHost.public.IPv4} tcp dport { 57912 } dnat to 192.0.2.3
          ip daddr ${thisHost.public.IPv4} udp dport { 57912 } dnat to 192.0.2.3
        ''}
        ${pkgs.lib.optionalString (pkgs.lib.hasAttrByPath [ "public" "IPv6Subnet" ] thisHost) ''
          ip6 daddr ${thisHost.public.IPv6Subnet}2 dnat to fc00::2
          ip6 daddr ${thisHost.public.IPv6Subnet}3 dnat to fc00::3
        ''}
      }

      chain NAT_INPUT {
        type nat hook input priority 105; policy accept;
      }

      chain NAT_OUTPUT {
        type nat hook output priority -95; policy accept;
      }

      chain NAT_POSTROUTING {
        type nat hook postrouting priority 105; policy accept;

        # wg-lantian
        ${pkgs.lib.optionalString (pkgs.lib.hasAttrByPath [ "public" "IPv6Subnet" ] thisHost) ''
          ip6 saddr fc00::2 snat to ${thisHost.public.IPv6Subnet}2
          ip6 saddr fc00::3 snat to ${thisHost.public.IPv6Subnet}3
        ''}

        oifname "eth*" masquerade
        oifname "virbr*" masquerade
      }

      # Helper chains
      chain DN42_INPUT {
        ip saddr 172.20.0.0/14 return
        ip saddr 172.31.0.0/16 return
        ip saddr 10.0.0.0/8 return
        ip saddr 169.254.0.0/16 return
        ip saddr 192.168.0.0/16 return
        ip saddr 224.0.0.0/4 return
        ip6 saddr fd00::/8 return
        ip6 saddr fe80::/10 return
        ip6 saddr ff00::/8 return
        reject with icmpx type admin-prohibited
      }

      chain DN42_OUTPUT {
        ip daddr 172.20.0.0/14 return
        ip daddr 172.31.0.0/16 return
        ip daddr 10.0.0.0/8 return
        ip daddr 169.254.0.0/16 return
        ip daddr 192.168.0.0/16 return
        ip daddr 224.0.0.0/4 return
        ip6 daddr fd00::/8 return
        ip6 daddr fe80::/10 return
        ip6 daddr ff00::/8 return
        reject with icmpx type admin-prohibited
      }
    }
  '';
in
{
  systemd.services.nftables = {
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
}
