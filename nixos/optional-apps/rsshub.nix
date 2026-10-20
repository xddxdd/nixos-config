{
  LT,
  ...
}:
{
  services.rsshub = {
    enable = true;
    settings = {
      PORT = LT.port.RSSHub;
      CACHE_CONTENT_EXPIRE = "600";
    };
    redis = {
      enable = true;
      createLocally = true;
      host = "127.0.0.1";
    };
  };

  systemd.services.rsshub.serviceConfig = LT.serviceHarden // {
    # Node's V8 JIT needs executable memory.
    MemoryDenyWriteExecute = false;
    # RSSHub enumerates local interfaces at startup via Node/libuv's netlink socket.
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];
  };
  lantian.harden.rsshub = true;

  # Redis inherits hardening and confinement from redis-auto-harden.nix.
  systemd.services.redis-rsshub.serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
  };

  lantian.nginxVhosts."rsshub.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.RSSHub}";
      };
    };

    sslCertificate = "lets-encrypt-xuyh0120.win";
    noIndex.enable = true;
    accessibleBy = "private";
  };
}
