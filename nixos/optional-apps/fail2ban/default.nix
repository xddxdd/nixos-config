{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  environment.etc = {
    "fail2ban/action.d/nftables-lantian.conf".source = lib.mkForce ./action.d/nftables-lantian.conf;
    "fail2ban/filter.d/asterisk-lantian.conf".source = lib.mkForce ./filter.d/asterisk-lantian.conf;
  };
  environment.systemPackages = [
    config.services.fail2ban.package
  ];

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    banaction = "nftables-lantian[type=allports]";
    banaction-allports = "nftables-lantian[type=allports]";
    packageFirewall = pkgs.nftables;
    ignoreIP = with LT.constants; (reserved.IPv4 ++ reserved.IPv6);

    bantime-increment = {
      enable = true;
      overalljails = true;
    };

    jails.sshd.settings.enable = lib.mkForce false;
  };

  systemd.services.fail2ban.path = [ pkgs.gnugrep ];

  systemd.services.fail2ban.serviceConfig.RestrictAddressFamilies = [
    "AF_UNIX"
    "AF_INET"
    "AF_INET6"
    "AF_NETLINK"
  ];

  lantian.harden.fail2ban = {
    enable = true;
    # journald 后端调用 systemd-path；Python 的 libc 探测还会尝试 gcc 和 ld。
    enableTripwire = false;
    enableConfinement = false;
  };
}
