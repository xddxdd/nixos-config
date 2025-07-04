{ lib, ... }:
rec {
  # Run asterisk-music-deploy after changing this list
  asteriskMusics = [
    "蔡健雅 - Nightglow.flac"
    "周深 - Rubia.flac"
    "不才 三体宇宙 - 夜航星 (Night Voyager).flac"
    "Tielle SawanoHiroyuki［nZk］ - Cage.flac"
    "阿鲲 - 550W   Moss.flac"
    "G.E.M.邓紫棋 - 来自天堂的魔鬼.flac"
    "杨凯琳 余枫 - 怎么还不爱 (雀跃狂爱版).mp3"
    "陈奕迅 - 孤勇者.mp3"
    "祖娅纳惜 - 孤勇者.mp3"
    "HOYO-MiX - 戏剧性反讽 A Dramatic Irony.flac"
    "HOYO-MiX - 轻涟 La vaguelette.flac"
    "HITA - 赤伶.flac"
    "HOYO-MiX - 纳塔 Natlan.flac"
    "周深 - 浮游.flac"
    "周深 - 能解答一切的答案.flac"
    "洛天依Official 哈拉木吉 - 天上的风.flac"
    "洛天依Official 旦增益西 - 雪山之眼.flac"
    "洛天依Official - 歌行四方.flac"
    "萨吉 - 玄鸟.flac"
    "F.I.R. 彭佳慧 - 心之火.flac"
    "刘欢 - 天地在我心 (Live).flac"
    "刘欢 - 带着地球去流浪.flac"
    "刘欢 - 我在.flac"
    "萨顶顶 - 左手指月.flac"
    "豆腐P 东方栀子 - 我将沐火而唱.flac"
    "陈姿彤 - 我的世界.flac"
    "陈姿彤 - 战争世界.flac"
    "黄霄雲 - 以我之躯.flac"
    "齐栾 - Seek The Peace feat. soratan小空（For the peace 翻自 Yisabel）（Cover 齐栾）.mp3"
  ];

  bindfsMountOptions = bindfsMountOptions' [
    "force-user=lantian"
    "force-group=lantian"
    "create-for-user=root"
    "create-for-group=root"
  ];

  bindfsMountOptions' =
    args:
    args
    ++ [
      "chown-ignore"
      "chgrp-ignore"
      "xattr-none"
      "x-gvfs-hide"
      "x-gdu.hide"
      "multithreaded"
    ];

  bindMountOptions = [
    "bind"
    "x-gvfs-hide"
    "x-gdu.hide"
  ];

  dn42 = {
    IPv4 = [
      "172.20.0.0/14"
      "172.31.0.0/16"
      "10.0.0.0/8"
    ];

    IPv6 = [ "fd00::/8" ];
  };

  neonetwork = {
    IPv4 = [ "10.127.0.0/16" ];

    IPv6 = [ "fd10:127::/32" ];
  };

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
    ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  port = {
    Whois = 43;
    DNS = 53; # CoreDNS public serving port
    DNSLocal = 54; # CoreDNS local-only service port
    DNSUpstream = 55; # CoreDNS DoT proxy port
    Gopher = 70;
    HTTP = 80;
    Quassel.Ident = 113;
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
    Quassel.Main = 4242;
    Yggdrasil.Alfis = 4244;
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
    Prowlarr = 9696;
    Prometheus.Palworld = 9877;
    PeerBanHelper = 9898;
    FakeOllama = 11434;
    Yggdrasil.Multicast = 13059;
    FlapAlerted.BGP = 13179;
    FlapAlerted.WebUI = 13180;
    FlareSolverr = 13191;
    Lemmy.API = 13200;
    Lemmy.UI = 13201;
    Pict-RS = 13202;
    Bepasty = 13237;
    ASF = 13242;
    RSSHub = 13248;
    NeteaseUnlock.HTTP = 13301;
    NeteaseUnlock.HTTPS = 13302;
    Dex = 13403;
    OpenWebUI.UI = 13433;
    Ollama = 13434;
    OpenWebUI.Redis = 13435;
    OneAPI = 13436;
    UniAPI = 13437;
    Mcpo = 13438;
    Iodine = 13453;
    Immich = 13466;
    Radicale = 13532;
    Tachidesk = 13567;
    Pterodactyl.Redis = 13679;
    Pterodactyl.Wings = 13680;
    Vaultwarden = 13772;
    StableDiffusionWebUI = 13786;
    Tika = 13787;
    OpenedAISpeech = 13788;
    OpenAIEdgeTTS = 13789;
    FishSpeech = 13790;
    MTranServer = 13791;
    Plausible = 13800;
    Netbox = 13801;
    Attic = 13803;
    qBitTorrent.WebUI = 13808;
    SakuraLLM = 13810;
    HomepageDashboard = 13812;
    Syncthing = 13834;
    Usque = 13840;
    Qinglong = 13857;
    Dump1090.RawInput = 13901;
    Dump1090.RawOutput = 13902;
    Dump1090.BaseStation = 13903;
    Dump1090.BeastInput = 13904;
    Dump1090.BeastOutput = 13905;
    Dump1090.Stratux = 13906;
    Dump978.Raw = 13978;
    Dump978.Json = 13979;
    Open5GS = 13999;
    WGLanTian.ForwardStart = 30010;
    WGLanTian.ForwardStop = 32559;
    Pipewire.RTP = 46414;
  };

  portStr = lib.mapAttrsRecursive (k: builtins.toString) port;

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
    "exclude-bgp-mesh"
    "nix-builder"
    "nixpkgs-old-cuda"
    "nixpkgs-stable"
    "public-facing"
    "server"

    # Hardware
    "i915-sriov"
    "low-disk"
    "low-ram"
    "qemu"
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
    OVERLAY = [
      "ygg"
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
    YggdrasilAlfis = [
      "anon"
      "btn"
      "conf"
      "index"
      "merch"
      "mirror"
      "mob"
      "screen"
      "srv"
      "ygg"
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
      # Lan Tian Mobile VoLTE
      "mnc001.mcc001.3gppnetwork.org"
      "mnc010.mcc315.3gppnetwork.org"
      "mnc999.mcc999.3gppnetwork.org"
    ];
  };
}
