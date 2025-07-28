{
  pkgs,
  lib,
  LT,
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

    settings =
      let
        ipv4Allow = lib.concatMapStringsSep " " (v: v) LT.constants.reserved.IPv4;
        ipv6Allow = lib.concatMapStringsSep " " (
          v:
          let
            splitted = lib.splitString "/" v;
          in
          "[${builtins.elemAt splitted 0}]/${builtins.elemAt splitted 1}"
        ) LT.constants.reserved.IPv6;
      in
      {
        global = {
          "netbios name" = config.networking.hostName;
          "server string" = config.networking.hostName;
          "hosts allow" = "localhost ${ipv4Allow} ${ipv6Allow}";
          "hosts deny" = "0.0.0.0/0 ::/0";
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
