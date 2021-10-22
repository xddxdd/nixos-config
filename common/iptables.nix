{ config, pkgs, modules, ... }:

let
  hosts = import ../hosts.nix;
  thisHost = builtins.getAttr config.networking.hostName hosts;
in
{
  networking.localCommands = ''
    # Allow everything by default
    ${pkgs.iptables}/bin/iptables -P INPUT ACCEPT
    ${pkgs.iptables}/bin/iptables -P FORWARD ACCEPT
    ${pkgs.iptables}/bin/iptables -P OUTPUT ACCEPT
    ${pkgs.iptables}/bin/ip6tables -P INPUT ACCEPT
    ${pkgs.iptables}/bin/ip6tables -P FORWARD ACCEPT
    ${pkgs.iptables}/bin/ip6tables -P OUTPUT ACCEPT

    # Flush everything
    ${pkgs.iptables}/bin/iptables -F INPUT
    ${pkgs.iptables}/bin/iptables -F FORWARD
    ${pkgs.iptables}/bin/iptables -F OUTPUT
    ${pkgs.iptables}/bin/iptables -t nat -F PREROUTING
    ${pkgs.iptables}/bin/iptables -t nat -F INPUT
    ${pkgs.iptables}/bin/iptables -t nat -F OUTPUT
    ${pkgs.iptables}/bin/iptables -t nat -F POSTROUTING
    ${pkgs.iptables}/bin/ip6tables -F INPUT
    ${pkgs.iptables}/bin/ip6tables -F FORWARD
    ${pkgs.iptables}/bin/ip6tables -F OUTPUT
    ${pkgs.iptables}/bin/ip6tables -t nat -F PREROUTING
    ${pkgs.iptables}/bin/ip6tables -t nat -F INPUT
    ${pkgs.iptables}/bin/ip6tables -t nat -F OUTPUT
    ${pkgs.iptables}/bin/ip6tables -t nat -F POSTROUTING

    # Drop timestamp ICMP pkts
    ${pkgs.iptables}/bin/iptables -I INPUT -p icmp --icmp-type timestamp-request -j DROP
    ${pkgs.iptables}/bin/iptables -I INPUT -p icmp --icmp-type timestamp-reply -j DROP

    # DN42 firewall rules
    ${pkgs.iptables}/bin/iptables -A FORWARD -i dn42+ -o eth0 -j REJECT
    ${pkgs.iptables}/bin/iptables -A FORWARD -i dn42+ -o henet -j REJECT

    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -d 172.20.0.0/14 -j SNAT --to-source ${thisHost.dn42.IPv4}
    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -d 172.31.0.0/16 -j SNAT --to-source ${thisHost.dn42.IPv4}
    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -d 10.0.0.0/8 -j SNAT --to-source ${thisHost.dn42.IPv4}

    # NAT internal requests
    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o virbr+ -j MASQUERADE
    ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fc00::/7 -o eth+ -j MASQUERADE
    ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fc00::/7 -o virbr+ -j MASQUERADE
    ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s fc00::/7 -o henet -j MASQUERADE

    # Block non-DN42 traffic in DN42
    ${pkgs.iptables}/bin/iptables -N DN42_INPUT || true
    ${pkgs.iptables}/bin/iptables -F DN42_INPUT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -s 172.20.0.0/14 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -s 172.31.0.0/16 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -s 10.0.0.0/8 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -s 169.254.0.0/16 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -s 192.168.0.0/16 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -s 224.0.0.0/4 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_INPUT -j REJECT
    ${pkgs.iptables}/bin/iptables -A INPUT -i dn42+ -j DN42_INPUT

    ${pkgs.iptables}/bin/iptables -N DN42_OUTPUT || true
    ${pkgs.iptables}/bin/iptables -F DN42_OUTPUT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -d 172.20.0.0/14 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -d 172.31.0.0/16 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -d 10.0.0.0/8 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -d 169.254.0.0/16 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -d 192.168.0.0/16 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -d 224.0.0.0/4 -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A DN42_OUTPUT -j REJECT
    ${pkgs.iptables}/bin/iptables -A OUTPUT -o dn42+ -j DN42_OUTPUT

    ${pkgs.iptables}/bin/ip6tables -N DN42_INPUT || true
    ${pkgs.iptables}/bin/ip6tables -F DN42_INPUT
    ${pkgs.iptables}/bin/ip6tables -A DN42_INPUT -s fd00::/8 -j ACCEPT
    ${pkgs.iptables}/bin/ip6tables -A DN42_INPUT -s fe80::/10 -j ACCEPT
    ${pkgs.iptables}/bin/ip6tables -A DN42_INPUT -s ff00::/8 -j ACCEPT
    ${pkgs.iptables}/bin/ip6tables -A DN42_INPUT -j REJECT
    ${pkgs.iptables}/bin/ip6tables -A INPUT -i dn42+ -j DN42_INPUT

    ${pkgs.iptables}/bin/ip6tables -N DN42_OUTPUT || true
    ${pkgs.iptables}/bin/ip6tables -F DN42_OUTPUT
    ${pkgs.iptables}/bin/ip6tables -A DN42_OUTPUT -d fd00::/8 -j ACCEPT
    ${pkgs.iptables}/bin/ip6tables -A DN42_OUTPUT -d fe80::/10 -j ACCEPT
    ${pkgs.iptables}/bin/ip6tables -A DN42_OUTPUT -d ff00::/8 -j ACCEPT
    ${pkgs.iptables}/bin/ip6tables -A DN42_OUTPUT -j REJECT
    ${pkgs.iptables}/bin/ip6tables -A OUTPUT -o dn42+ -j DN42_OUTPUT

    ${pkgs.iptables}/bin/iptables -A FORWARD -i dn42+ -j DN42_INPUT
    ${pkgs.iptables}/bin/iptables -A FORWARD -o dn42+ -j DN42_OUTPUT
    ${pkgs.iptables}/bin/iptables -A FORWARD -j ACCEPT

    ${pkgs.iptables}/bin/ip6tables -A FORWARD -i dn42+ -j DN42_INPUT
    ${pkgs.iptables}/bin/ip6tables -A FORWARD -o dn42+ -j DN42_OUTPUT
    ${pkgs.iptables}/bin/ip6tables -A FORWARD -j ACCEPT

    exit 0
  '';

  environment.systemPackages = with pkgs; [
    iptables
  ];
}
