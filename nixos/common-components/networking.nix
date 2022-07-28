{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
in
{
  boot.kernel.sysctl = lib.mkIf (!config.boot.isContainer) {
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # https://wiki.archlinux.org/title/sysctl
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_max_tw_buckets" = 2000000;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_syncookies" = 1;

    "net.ipv4.conf.all.forwarding" = lib.mkForce 1;
    "net.ipv4.conf.default.forwarding" = lib.mkForce 1;
    "net.ipv4.conf.*.forwarding" = lib.mkForce 1;
    "net.ipv6.conf.all.forwarding" = lib.mkForce 1;
    "net.ipv6.conf.default.forwarding" = lib.mkForce 1;
    "net.ipv6.conf.*.forwarding" = lib.mkForce 1;

    "net.ipv4.conf.all.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.default.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.*.rp_filter" = lib.mkForce 0;
    "net.ipv4.conf.all.accept_redirects" = lib.mkForce 0;
    "net.ipv4.conf.default.accept_redirects" = lib.mkForce 0;
    "net.ipv4.conf.*.accept_redirects" = lib.mkForce 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.*.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.*.send_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = lib.mkForce 0;
    "net.ipv6.conf.default.accept_redirects" = lib.mkForce 0;
    "net.ipv6.conf.*.accept_redirects" = lib.mkForce 0;
  };

  networking = {
    hostId = builtins.readFile (pkgs.runCommandLocal "hostid.txt" { } ''
      echo -n ${config.networking.hostName} | cksum | cut -d" " -f1 | xargs echo printf '%0X' | sh > $out
    '');
    usePredictableInterfaceNames = false;
    useDHCP = false;
    domain = "lantian.pub";
    firewall.enable = false;
    firewall.checkReversePath = false;
    iproute2.enable = true;
    nat.enable = false;
    resolvconf.dnsExtensionMechanism = true;
    resolvconf.dnsSingleRequest = true;
    search = [ "lantian.pub" ];
    tempAddresses = "disabled";

    # Use NixOS networking scripts for DNS
    # useNetworkd = true;
  };

  systemd.network.enable = true;
  environment.etc."systemd/networkd.conf".text = ''
    [Network]
    ManageForeignRoutes=false
    ManageForeignRoutingPolicyRules=false
  '';
  systemd.services.systemd-networkd.restartIfChanged = false;
  systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
    "" # clear old command
    "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];
  services.resolved.enable = false;

  # Disable systemd-nspawn container's default addresses.
  environment.etc."systemd/network/80-container-ve.network".text = ''
    [Match]
    Name=ve-*
    Driver=veth

    [Network]
    LinkLocalAddressing=ipv6
    DHCPServer=no
    IPMasquerade=both
    LLDP=no
    IPv6SendRA=no
  '';

  # Multicast DNS
  services.avahi = {
    enable = true;
    nssmdns = true;
    interfaces = [ "ltmesh" ];
    publish = {
      enable = true;
      addresses = true;
      hinfo = true;
      workstation = true;
    };
  };

  # Support network namespaces
  systemd.tmpfiles.rules = [
    "d /run/netns 755 root root"
  ];
}
