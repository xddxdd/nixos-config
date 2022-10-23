{ config, pkgs, lib, ... }@args:

let
  LT = import ../../../helpers { inherit config pkgs lib; };

  setupPolicy = ''
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -t nat -P INPUT ACCEPT
    iptables -t nat -P OUTPUT ACCEPT
    iptables -t nat -P PREROUTING ACCEPT
    iptables -t nat -P POSTROUTING ACCEPT
    ip6tables -P INPUT ACCEPT
    ip6tables -P FORWARD ACCEPT
    ip6tables -P OUTPUT ACCEPT
    ip6tables -t nat -P INPUT ACCEPT
    ip6tables -t nat -P OUTPUT ACCEPT
    ip6tables -t nat -P PREROUTING ACCEPT
    ip6tables -t nat -P POSTROUTING ACCEPT
  '';

  newChain = name: ''
    iptables -N ${name} || true
    iptables -F ${name}
    ip6tables -N ${name} || true
    ip6tables -F ${name}
  '';

  newNatChain = name: ''
    iptables -t nat -N ${name} || true
    iptables -t nat -F ${name}
    ip6tables -t nat -N ${name} || true
    ip6tables -t nat -F ${name}
  '';

  disableChains = ''
    iptables -D INPUT -j LT_INPUT || true
    ip6tables -D INPUT -j LT_INPUT || true
    iptables -D FORWARD -j LT_FORWARD || true
    ip6tables -D FORWARD -j LT_FORWARD || true
    iptables -D OUTPUT -j LT_OUTPUT || true
    ip6tables -D OUTPUT -j LT_OUTPUT || true
    iptables -t nat -D PREROUTING -j LT_NAT_PRE || true
    ip6tables -t nat -D PREROUTING -j LT_NAT_PRE || true
    iptables -t nat -D POSTROUTING -j LT_NAT_POST || true
    ip6tables -t nat -D POSTROUTING -j LT_NAT_POST || true
  '';

  createChains = ''
    ${newChain "LT_INPUT"}
    ${newChain "LT_FORWARD"}
    ${newChain "LT_OUTPUT"}
    ${newChain "DN42_INPUT"}
    ${newChain "DN42_OUTPUT"}
    ${newNatChain "LT_NAT_PRE"}
    ${newNatChain "LT_NAT_POST"}
  '';

  enableChains = ''
    iptables -A INPUT -j LT_INPUT
    ip6tables -A INPUT -j LT_INPUT
    iptables -A FORWARD -j LT_FORWARD
    ip6tables -A FORWARD -j LT_FORWARD
    iptables -A OUTPUT -j LT_OUTPUT
    ip6tables -A OUTPUT -j LT_OUTPUT
    iptables -t nat -A PREROUTING -j LT_NAT_PRE
    ip6tables -t nat -A PREROUTING -j LT_NAT_PRE
    iptables -t nat -A POSTROUTING -j LT_NAT_POST
    ip6tables -t nat -A POSTROUTING -j LT_NAT_POST
  '';

  dn42Chains = ''
    # DN42_INPUT chain
    ${lib.concatMapStringsSep "\n" (p: "iptables -A DN42_INPUT -s ${p} -j ACCEPT") LT.constants.dn42.IPv4}
    iptables -A DN42_INPUT -j REJECT

    ${lib.concatMapStringsSep "\n" (p: "ip6tables -A DN42_INPUT -s ${p} -j ACCEPT") LT.constants.dn42.IPv6}
    ip6tables -A DN42_INPUT -j REJECT

    # DN42_OUTPUT chain
    ${lib.concatMapStringsSep "\n" (p: "iptables -A DN42_OUTPUT -d ${p} -j ACCEPT") LT.constants.dn42.IPv4}
    iptables -A DN42_OUTPUT -j REJECT

    ${lib.concatMapStringsSep "\n" (p: "ip6tables -A DN42_OUTPUT -d ${p} -j ACCEPT") LT.constants.dn42.IPv6}
    ip6tables -A DN42_OUTPUT -j REJECT
  '';
in
''
  ${disableChains}
  ${setupPolicy}
  ${createChains}
  ${enableChains}
  ${dn42Chains}

  # Input chain
  iptables -I LT_INPUT -p icmp --icmp-type timestamp-request -j DROP
  iptables -I LT_INPUT -p icmp --icmp-type timestamp-reply -j DROP
  iptables -A LT_INPUT -i dn42+ -j DN42_INPUT
  ip6tables -A LT_INPUT -i dn42+ -j DN42_INPUT

  # Forward chain
  iptables -A LT_FORWARD -i dn42+ -o eth+ -j REJECT
  ip6tables -A LT_FORWARD -i dn42+ -o eth+ -j REJECT
  iptables -A LT_FORWARD -i dn42+ -o venet+ -j REJECT
  ip6tables -A LT_FORWARD -i dn42+ -o venet+ -j REJECT
  iptables -A LT_FORWARD -i dn42+ -o henet -j REJECT
  ip6tables -A LT_FORWARD -i dn42+ -o henet -j REJECT

  # Output chain
  iptables -A LT_OUTPUT -o dn42+ -j DN42_OUTPUT
  ip6tables -A LT_OUTPUT -o dn42+ -j DN42_OUTPUT

  # NAT Prerouting Chain
  # Empty for now

  # NAT Postrouting Chain
  # Empty for now
  iptables -t nat -A LT_NAT_POST -o eth+ -j MASQUERADE
  iptables -t nat -A LT_NAT_POST -o venet+ -j MASQUERADE
  iptables -t nat -A LT_NAT_POST -o virbr+ -j MASQUERADE
  iptables -t nat -A LT_NAT_POST -o wlan+ -j MASQUERADE
''
