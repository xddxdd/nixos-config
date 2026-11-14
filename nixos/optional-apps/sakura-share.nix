{
  config,
  pkgs,
  LT,
  ...
}:
let
  py = pkgs.python3.withPackages (
    ps: with ps; [
      requests
      aiohttp
    ]
  );
in
{
  sops.secrets.sakura-share-env = {
    sopsFile = LT.secret "sakura-share.yaml";
    owner = "sakura-share";
  };

  # Not enabled at boot; start manually with `systemctl start sakura-share`.
  systemd.services.sakura-share = {
    description = "Share client for sakura-share.one";
    after = [
      "network.target"
      "llama-swap.service"
      "nginx.service"
    ];
    requires = [
      "network.target"
      "llama-swap.service"
      "nginx.service"
    ];
    bindsTo = [ "llama-swap.service" ];

    path = [ py ];

    # Requests are forwarded to llama-swap, which loads and unloads the model
    # server according to its swap groups.
    script = ''
      python3 -u ${LT.sources.sakura-share.src}/src/sakura_share_cli.py \
        --port ${LT.portStr.SakuraLLM} \
        --tg-token "$TG_TOKEN" \
        --action start \
        --mode ws
    '';

    serviceConfig = {
      Restart = "on-failure";
      # Wait 60s between connection attempts, otherwise batched tasks cause
      # inference inconsistency and fail validation
      RestartSec = 60;
      EnvironmentFile = config.sops.secrets.sakura-share-env.path;

      User = "sakura-share";
      Group = "sakura-share";
    };
  };

  lantian.harden.sakura-share = {
    enable = true;
    secret = true; # sops environment file below /run/secrets
  };

  # The worker names no model, so its requests are pinned to the sakura model
  # through llama-swap's upstream passthrough; loopback only.
  services.nginx.virtualHosts."sakura-llm-share" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = LT.port.SakuraLLM;
      }
    ];
    serverName = "localhost";
    locations."/" = {
      # proxy_pass is rendered as a variable, which skips URI rewriting, so the
      # passthrough prefix has to come from an explicit rewrite.
      proxyPass = "http://127.0.0.1:${LT.portStr.LlamaSwap}";
      extraConfig = ''
        rewrite ^/(.*)$ /upstream/sakura-llm/$1 break;
        client_body_buffer_size 512k;
        client_body_timeout 52w;
        client_max_body_size 0;
        keepalive_timeout 52w;
        proxy_connect_timeout 60;
        proxy_read_timeout 52w;
        proxy_send_timeout 52w;
        send_timeout 52w;
      '';
    };
  };

  users.users.sakura-share = {
    group = "sakura-share";
    isSystemUser = true;
  };
  users.groups.sakura-share = { };
}
