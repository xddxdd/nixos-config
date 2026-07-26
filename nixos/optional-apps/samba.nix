{
  pkgs,
  lib,
  config,
  ...
}:
{
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
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
  });
}
