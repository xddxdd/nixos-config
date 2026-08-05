{
  inputs,
  pkgs,
  config,
  lib,
  LT,
  ...
}:
let
  explorer = LT.nginx.compressStaticAssets (
    pkgs.radicle-explorer.withConfig {
      preferredSeeds = [
        {
          hostname = "radicle.lantian.pub";
          port = 443;
          scheme = "https";
        }
      ];
    }
  );
in
{
  sops.secrets.radicle-public-key = {
    sopsFile = inputs.secrets + "/per-host/radicle/${config.networking.hostName}.yaml";
    owner = "radicle";
    group = "radicle";
  };
  sops.secrets.radicle-private-key = {
    sopsFile = inputs.secrets + "/per-host/radicle/${config.networking.hostName}.yaml";
    owner = "radicle";
    group = "radicle";
  };

  services.radicle = {
    enable = true;
    privateKey = config.sops.secrets.radicle-private-key.path;
    publicKey = config.sops.secrets.radicle-public-key.path;

    node.listenPort = LT.port.Radicle.Node;

    settings = {
      publicExplorer = "https://radicle.network/nodes/$host/$rid$path";
      preferredSeeds = [
        "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@iris.radicle.network:8776"
        "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@irisradizskwweumpydlj4oammoshkxxjur3ztcmo7cou5emc6s5lfid.onion:8776"
        "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosa.radicle.network:8776"
        "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@rosarad5bxgdlgjnzzjygnsxrwxmoaj4vn7xinlstwglxvyt64jlnhyd.onion:8776"
      ];
      cli = {
        hints = true;
      };
      node = {
        alias = "lantian-${config.networking.hostName}";
        peers.type = "dynamic";
        externalAddresses =
          (lib.optionals (LT.this.public.IPv4 != null) [
            "${LT.this.public.IPv4}:${LT.portStr.Radicle.Node}"
          ])
          ++ (lib.optionals (LT.this.public.IPv6 != null) [
            "[${LT.this.public.IPv6}]:${LT.portStr.Radicle.Node}"
          ]);
        network = "main";
        log = "WARN";
        relay = "auto";
        limits = {
          routingMaxSize = 1000;
          routingMaxAge = 604800;
          gossipMaxAge = 1209600;
          fetchConcurrency = 1;
          maxOpenFiles = 4096;
          rate = {
            inbound = {
              fillRate = 5.0;
              capacity = 1024;
            };
            outbound = {
              fillRate = 10.0;
              capacity = 2048;
            };
          };
          connection = {
            inbound = 128;
            outbound = 16;
          };
          fetchPackReceive = "500.0 MiB";
        };
        workers = 8;
        seedingPolicy.default = "block";
      };
    };
  };

  services.radicle.httpd = {
    enable = true;
    listenAddress = "127.0.0.1";
    listenPort = LT.port.Radicle.HTTPd;
  };

  systemd.tmpfiles.settings = {
    radicle-public-key = {
      "/var/lib/radicle/keys/radicle.pub"."C+" = {
        argument = config.sops.secrets.radicle-public-key.path;
      };
    };
  };

  lantian.nginxVhosts."radicle.lantian.pub" = {
    root = builtins.toString explorer;
    locations = {
      "/" = {
        index = "index.html index.htm";
        tryFiles = "$uri $uri/ /index.html";
      };
      "/api/v1" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Radicle.HTTPd}";
      };
      "~ \\.git(/.*)?$" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.Radicle.HTTPd}";
      };
    };

    sslCertificate = "zerossl-lantian.pub";
    disableLiveCompression = true;
  };
}
