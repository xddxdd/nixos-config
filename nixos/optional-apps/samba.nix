{
  pkgs,
  lib,
  LT,
  config,
  ...
}:
{
  lantian.firewall.presets.public-firewall.firewalledPorts = lib.mkIf config.services.samba.enable [
    137
    138
    139
    445
  ];

  services.samba = {
    enable = true;
    nmbd.enable = true;
    winbindd.enable = true;

    package = pkgs.samba4Full.override { enableCephFS = false; };
    nsswins = true;

    settings = {
      global = {
        "netbios name" = config.networking.hostName;
        "server string" = config.networking.hostName;
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "printing" = "CUPS";
        "mangled names" = "no";

        # Performance tuning
        # https://hilltopsw.com/blog/faster-samba-smb-cifs-share-performance/
        "min receivefile size" = 16384;
        "getwd cache" = "yes";
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "read raw" = "yes";
        "write raw" = "yes";
        "server signing" = "no";
        "strict locking" = "no";
        "use sendfile" = "yes";
        "aio read size" = 16384;
        "aio write size" = 16384;
        "server multi channel support" = "yes";
        # NOTE: Do NOT set "interfaces" to glob patterns like "br*"/"en*".
        # Samba's `net` tool resolves every entry in `interfaces` via
        # gethostbyname(), and a glob (e.g. "br*") is not an interface name, so
        # it falls through to a DNS NXDOMAIN lookup taking ~0.25s each. With
        # ~14 patterns this stalls any `net` invocation (notably
        # `net usershare info`, which Dolphin runs synchronously on startup)
        # for ~6 seconds, freezing the file manager on every launch.
        # `bind interfaces only` is not enabled, so `interfaces` would not
        # restrict listening sockets anyway; leaving it unset lets Samba use all
        # interfaces and keeps `net` instant.

        # Windows XP access
        "server min protocol" = "NT1";
        "lanman auth" = "yes";
        "ntlm auth" = "yes";
      };

      "printers" = {
        "path" = "/var/tmp";
        "printable" = "yes";
        "valid users" = "lantian";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
  };

  systemd.services = lib.genAttrs [ "samba-nmbd" "samba-smbd" "samba-winbindd" "samba-wsdd" ] (n: {
    serviceConfig = LT.serviceHarden // {
      Restart = "always";
      RestartSec = 5;

      # samba dlopens NSS modules at runtime, and enumerates network
      # interfaces over netlink; per-connection uid/gid switching and
      # file access need extra capabilities
      AmbientCapabilities = lib.mkForce [
        "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"
        "CAP_DAC_READ_SEARCH"
        "CAP_FOWNER"
        "CAP_NET_BIND_SERVICE"
        "CAP_SETGID"
        "CAP_SETUID"
      ];
      CapabilityBoundingSet = lib.mkForce [
        "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"
        "CAP_DAC_READ_SEARCH"
        "CAP_FOWNER"
        "CAP_NET_BIND_SERVICE"
        "CAP_SETGID"
        "CAP_SETUID"
      ];
      MemoryDenyWriteExecute = lib.mkForce false;
      RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      # keep @privileged allowed: smbd needs setuid/setgroups per connection
      SystemCallFilter = lib.mkForce [
        "@system-service"
        "~@clock @cpu-emulation @debug @obsolete @raw-io @reboot @swap"
      ];

      # Writable samba state and log directories
      ReadWritePaths = [
        "/var/lib/samba"
        "/var/cache/samba"
        "/var/log/samba"
      ];
    };
  });

  systemd.tmpfiles.settings.samba = {
    "/var/lib/samba"."d" = { mode = "0700"; user = "root"; group = "root"; };
    "/var/cache/samba"."d" = { mode = "0755"; user = "root"; group = "root"; };
    "/var/log/samba"."d" = { mode = "0755"; user = "root"; group = "root"; };
  };
}
