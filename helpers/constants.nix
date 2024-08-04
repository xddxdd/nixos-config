{ lib, ... }:
rec {
  bindfsMountOptions = [
    "force-user=lantian"
    "force-group=lantian"
    "create-for-user=root"
    "create-for-group=root"
    "chown-ignore"
    "chgrp-ignore"
    "xattr-none"
    "x-gvfs-hide"
  ];

  bindMountOptions = [
    "bind"
    "x-gvfs-hide"
  ];

  dn42 = {
    IPv4 = [
      "172.20.0.0/14"
      "172.31.0.0/16"
      "10.0.0.0/8"
    ];

    IPv6 = [ "fd00::/8" ];
  };

  gui = {
    cursorSize = 32;
    fontSize = 10;
  };

  neonetwork = {
    IPv4 = [ "10.127.0.0/16" ];

    IPv6 = [ "fd10:127::/32" ];
  };

  dnssecKeys = [
    "K0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa.+013+11807"
    "K10.127.10.in-addr.arpa.+013+53292"
    "K184_29.76.22.172.in-addr.arpa.+013+08709"
    "K96_27.76.22.172.in-addr.arpa.+013+41969"
    "Kasn.lantian.pub.+013+48539"
    "Kd.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa.+013+18344"
    "Klantian.dn42.+013+20109"
    "Klantian.eu.org.+013+37106"
    "Klantian.neo.+013+47346"
  ];

  matrixWellKnown = {
    server = builtins.toJSON { "m.server" = "matrix.lantian.pub:${portStr.Matrix.Public}"; };
    client = builtins.toJSON {
      "m.server"."base_url" = "https://matrix.lantian.pub";
      "m.homeserver"."base_url" = "https://matrix.lantian.pub";
      "m.identity_server"."base_url" = "https://vector.im";
      "org.matrix.msc3575.proxy"."url" = "https://matrix.lantian.pub";
    };
  };

  nix = {
    substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://cache.saumon.network/proxmox-nixos"
      "https://cache.lix.systems"
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "proxmox-nixos:nveXDuVVhFDRFx8Dn19f1WDEaNRJjPrF2CPD2D+m1ys="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
  };

  port = {
    Whois = 43;
    DNS = 53; # CoreDNS public serving port
    DNSLocal = 54; # CoreDNS local-only service port
    DNSUpstream = 55; # CoreDNS DoT proxy port
    Gopher = 70;
    HTTP = 80;
    LDAP = 389;
    HTTPS = 443;
    LDAPS = 636;
    Rsync = 873;
    V2Ray.SocksClient = 1080;
    KMS = 1688;
    Bitmagnet = 3333;
    NFS.StatD = 4000;
    NFS.LockD = 4001;
    NFS.MountD = 4002;
    Quassel = 4242;
    Pipewire.TCP = 4713;
    IPFS.API = 5001;
    IPerf = 5201;
    Bazarr = 6767;
    Radarr = 7878;
    ArchiveTeam = 8001;
    IPFS.Gateway = 8080;
    JProxy = 8117;
    Waline = 8360;
    Matrix.Public = 8448;
    Sonarr = 8989;
    Prometheus.Daemon = 9090;
    Transmission = 9091;
    Prometheus.AlertManager = 9093;
    Prometheus.NodeExporter = 9100;
    Prometheus.MySQLExporter = 9104;
    Prometheus.BlackboxExporter = 9115;
    Prometheus.PostgresExporter = 9187;
    Prometheus.CoreDNS = 9253;
    Prometheus.BirdExporter = 9324;
    Prometheus.EndlesshGo = 9322;
    Prowlarr = 9696;
    Prometheus.Palworld = 9877;
    PeerBanHelper = 9898;
    FlareSolverr = 13191;
    Lemmy.API = 13200;
    Lemmy.UI = 13201;
    Pict-RS = 13202;
    Bepasty = 13237;
    ASF = 13242;
    RSSHub = 13248;
    NeteaseUnlock.HTTP = 13301;
    NeteaseUnlock.HTTPS = 13302;
    Keycloak.HTTP = 13401;
    Keycloak.HTTPS = 13402;
    Tachidesk = 13567;
    Pterodactyl.Redis = 13679;
    Pterodactyl.Wings = 13680;
    Vaultwarden = 13772;
    GoAutoconfig.Start = 13780;
    GoAutoconfig.Stop = 13789;
    Plausible = 13800;
    Netbox = 13801;
    Attic = 13803;
    qBitTorrent.WebUI = 13808;
    LlamaCpp = 13810;
    Syncthing = 13834;
    WGLanTian.ForwardStart = 30010;
    WGLanTian.ForwardStop = 32559;
    Pipewire.RTP = 46414;
  };

  portStr = lib.mapAttrsRecursive (_k: builtins.toString) port;

  reserved = {
    IPv4 = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.0.0.0/24"
      "192.0.2.0/24"
      "192.168.0.0/16"
      "198.18.0.0/15"
      "198.51.100.0/24"
      "203.0.113.0/24"
      "233.252.0.0/24"
      "240.0.0.0/4"
    ];

    IPv6 = [
      "2001:2::/48"
      "2001:20::/28"
      "2001:db8::/32"
      "64:ff9b::/96"
      "64:ff9b:1::/48"
      "fc00::/7"
    ];
  };

  stateVersion = "24.05";

  soundfontPath = pkgs: "${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2";

  tags = lib.genAttrs [
    # Usage
    "client"
    "dn42"
    "nix-builder"
    "public-facing"
    "server"

    # Hardware
    "i915-sriov"
    "low-disk"
    "low-ram"
    "qemu"
    "x86_64-v1"
  ] (v: v);

  interfacePrefixes = {
    WAN = [
      "en"
      "eth"
      "henet"
      "usb"
      "venet"
      "wan"
      "wl"
      # "wlan" # covered by wl
    ];
    DN42 = [
      "dn42"
      "neo"
    ];
    LAN = [
      "lan"
      "ns"
      "vboxnet"
      "virbr"
    ];
  };

  zones = {
    DN42 = [
      "dn42"
      "10.in-addr.arpa"
      "20.172.in-addr.arpa"
      "21.172.in-addr.arpa"
      "22.172.in-addr.arpa"
      "23.172.in-addr.arpa"
      "31.172.in-addr.arpa"
      "d.f.ip6.arpa"
    ];
    NeoNetwork = [ "neo" ];
    # .neo zone not included for conflict with NeoNetwork
    OpenNIC = [
      "bbs"
      "chan"
      "cyb"
      "dns.opennic.glue"
      "dyn"
      "epic"
      "fur"
      "geek"
      "gopher"
      "indy"
      "libre"
      "null"
      "o"
      "opennic.glue"
      "oss"
      "oz"
      "parody"
      "pirate"
    ];
    Emercoin = [
      "bazar"
      "coin"
      "emc"
      "lib"
    ];
    CRXN = [ "crxn" ];
    Ltnet = [
      "0.1.0.0.7.2.1.0.0.1.d.f.ip6.arpa"
      "10.127.10.in-addr.arpa"
      "18.198.in-addr.arpa"
      "19.198.in-addr.arpa"
      "d.a.7.6.c.d.9.f.c.b.d.f.ip6.arpa"
      "lantian.dn42"
      "lantian.neo"
    ];
  };
}
