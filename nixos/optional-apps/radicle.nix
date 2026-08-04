{
  inputs,
  config,
  lib,
  LT,
  ...
}:
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
            "${LT.this.public.IPv4}:8776"
          ])
          ++ (lib.optionals (LT.this.public.IPv6 != null) [
            "[${LT.this.public.IPv6}]:8776"
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

  systemd.tmpfiles.settings = {
    radicle-public-key = {
      "/var/lib/radicle/keys/radicle.pub"."C+" = {
        argument = config.sops.secrets.radicle-public-key.path;
      };
    };
  };
}
