{
  LT,
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  hydraServices = [
    "hydra-builder"
    "hydra-check-space"
    "hydra-compress-logs"
    "hydra-evaluator"
    "hydra-notify"
    "hydra-queue-runner"
    "hydra-send-stats"
    "hydra-server"
    "hydra-update-gc-roots"
    "hydra-ws"
  ];
  hydraConf = pkgs.writeScript "hydra.conf" config.services.hydra.extraConfig;
  queueRunnerToken = config.lantian.secrets.hydra-queue-runner-token.path;
  py = pkgs.python3.withPackages (
    ps: with ps; [
      pydantic
      requests
    ]
  );
  path = lib.makeBinPath [
    pkgs.attic-client
    pkgs.gitMinimal
    pkgs.jq
  ];

  hydra-post-build = pkgs.writeShellScript "post-build" ''
    export PATH="${path}:$PATH"
    export HYDRA_URL="http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra.WebUI}"

    jq . "$HYDRA_JSON"
    exec ${lib.getExe' py "python3"} ${./post-build.py} "$HYDRA_JSON"
  '';
in
{
  imports = [
    ../nix-distributed.nix
    ../postgresql.nix
  ];

  sops.secrets.hydra-attic-push-token = {
    sopsFile = inputs.secrets + "/hydra.yaml";
    mode = "0440";
    owner = "hydra-queue-runner";
    group = "hydra";
  };
  # hydra-server runs as hydra-www, with primary group hydra.
  sops.secrets.dex-hydra-secret = {
    sopsFile = inputs.secrets + "/dex/hydra.yaml";
    mode = "0440";
    owner = "hydra";
    group = "hydra";
  };

  # Only the local builder connects to the loopback queue runner.
  lantian.secrets.hydra-queue-runner-token = {
    mode = "0440";
    group = "hydra";
  };

  # Force use original nix for Hydra hosts
  nix.package = lib.mkForce pkgs.nixVersions.latest;

  services.hydra = {
    enable = true;
    # FIXME: disable failing checks
    package = pkgs.hydra.overrideAttrs (old: {
      doCheck = false;
      patches = (old.patches or [ ]) ++ [ ./evaluation-command-timeout.patch ];
    });
    hydraURL = "https://hydra.lantian.pub";
    listenHost = LT.this.ltnet.IPv4;
    notificationSender = "postmaster@lantian.pub";
    port = LT.port.Hydra.WebUI;
    useSubstitutes = true;

    maxServers = 10;
    maxSpareServers = 2;
    minSpareServers = 1;

    queueRunner = {
      grpc = {
        address = "127.0.0.1";
        port = LT.port.Hydra.QueueRunnerGRPC;
      };
      rest = {
        address = "127.0.0.1";
        port = LT.port.Hydra.QueueRunnerREST;
      };
      settings = {
        # https://github.com/nixos-cuda/infra/pull/144
        maxOutputSize = 1024 * 1024 * 1024 * 1024; # 1TB
        machineFreeFn = "DynamicWithMaxJobLimit";
        maxUnsupportedTimeInS = 3600; # Avoid unstable queue runners aborting builds
        tokenPaths = [ queueRunnerToken ];
        maxSilentTime = 6 * 3600;
        buildTimeout = 12 * 3600;
      };
    };

    ws = {
      bind = {
        address = LT.this.ltnet.IPv4;
        port = LT.port.Hydra.WebSocket;
      };
    };

    extraConfig = ''
      # Required for custom scripts
      local_auth_enabled = 1
      # Read by Hydra::Helper::LogEndpoints; any path works, hydra-ws accepts
      # upgrades on every path. Proxied at /ws on the public-facing hosts.
      ws_endpoint = wss://hydra.lantian.pub/ws

      <runcommand>
        job = *:*:*
        command = ${hydra-post-build}
      </runcommand>

      <oidc>
        <provider dex>
          display_name = "Dex"
          discovery_url = "https://login.lantian.pub/.well-known/openid-configuration"
          client_id = "hydra"
          client_secret_file = "${config.sops.secrets.dex-hydra-secret.path}"
          # Dex only puts `groups` into the issued ID token when the client
          # requests the `groups` scope; group name convention follows
          # grafana.nix / nextcloud.nix
          extra_scopes = "groups"
          role_claim = "groups"
          <role_mapping>
            admin = admin
          </role_mapping>
        </provider>
      </oidc>

      allow_import_from_derivation = true

      # Read by hydra-eval-jobset; passed to nix-eval-jobs as --workers and
      # --max-memory-size. Enforced budget is workers * max-memory-size per
      # jobset eval, in MiB.
      evaluator_workers = 16
      evaluator_max_memory_size = 8192
    '';
  };

  services.hydra-builder = {
    enable = true;
    authorizationFile = queueRunnerToken;
    queueRunnerAddr = "http://127.0.0.1:${LT.portStr.Hydra.QueueRunnerGRPC}";
  };

  lantian.harden = lib.genAttrs hydraServices (_: true);

  systemd.services = lib.mkMerge [
    (lib.genAttrs hydraServices (_: {
      requires = [ "hydra-init.service" ];
      after = [ "hydra-init.service" ];
      serviceConfig = LT.serviceHarden // {
        BindReadOnlyPaths = [
          "/etc/passwd"
          "/etc/group"
          "${hydraConf}:/var/lib/hydra/hydra.conf"
        ];
      };
    }))
    {
      hydra-init = {
        requires = [ "sops-install-secrets.service" ];
        after = [ "sops-install-secrets.service" ];
      };

      hydra-server.serviceConfig = {
        RestartSec = "5s";
        BindPaths = [
          "/var/lib/hydra"
          config.services.hydra.gcRootsDir
        ];
        BindReadOnlyPaths = [
          # FIXME: secrets
          "/run"
          "/nix/store"
          "/nix/var/nix/daemon-socket"
          "/etc/nix"
          "/etc/static/nix"
          "/var/lib/hydra/build-logs"
          "/var/lib/hydra/runcommand-logs"
        ];
      };

      hydra-evaluator.serviceConfig = {
        RestartSec = "5s";
        BindPaths = [
          "/var/lib/hydra"
          config.services.hydra.gcRootsDir
        ];
        BindReadOnlyPaths = [
          "/run/postgresql"
          "/nix/store"
          "/nix/var/nix/daemon-socket"
          "/etc/nix"
          "/etc/static/nix"
          "/etc/hydra"
          "/etc/static/hydra"
          config.sops.templates.nix-include.path
        ];
      };

      hydra-notify = {
        environment.GITHUB_TOKEN_FILE = "%d/github-token";
        preStart = ''
          if [ ! -f "$HOME/.config/attic/config.toml" ]; then
            ${lib.getExe pkgs.attic-client} login --set-default lantian \
              https://cache.lantian.pub \
              $(cat $CREDENTIALS_DIRECTORY/hydra-attic-push-token)
          fi
        '';
        serviceConfig = {
          LoadCredential = [
            "github-token:${config.sops.secrets.nix-github-key.path}"
            "hydra-attic-push-token:${config.sops.secrets.hydra-attic-push-token.path}"
          ];
          BindPaths = [
            "/var/lib/hydra"
            config.services.hydra.gcRootsDir
          ];
          BindReadOnlyPaths = [
            "/run/postgresql"
            "/nix/store"
            "/nix/var/nix/daemon-socket"
            "/etc/nix"
            "/etc/static/nix"
            "/var/lib/hydra"
          ];
        };
      };

      hydra-queue-runner = {
        requires = [ "lantian-secrets.service" ];
        after = [ "lantian-secrets.service" ];
        serviceConfig = {
          OOMScoreAdjust = "1000";
          BindPaths = [
            "/var/lib/hydra"
            config.services.hydra.gcRootsDir
          ];
          BindReadOnlyPaths = [
            "/run/postgresql"
            "/nix/store"
            "/nix/var/nix/daemon-socket"
            "/etc/hydra"
            "/etc/static/hydra"
            queueRunnerToken
          ];
        };
      };

      hydra-builder = {
        requires = [
          "lantian-secrets.service"
          "nix-daemon.service"
        ];
        after = [
          "lantian-secrets.service"
          "nix-daemon.service"
        ];
        serviceConfig = {
          # Builder capacity and pressure reporting reads /proc/{meminfo,cpuinfo,pressure}.
          ProcSubset = "all";
          BindPaths = [
            "/nix/var/nix/gcroots"
            "/var/lib/hydra"
            config.services.hydra.gcRootsDir
          ];
          BindReadOnlyPaths = [
            "/nix/store"
            "/nix/var/nix/daemon-socket"
            "/etc/nix"
            "/etc/static/nix"
            "/etc/hydra"
            "/etc/static/hydra"
            config.nix.settings.build-dir
            config.sops.templates.nix-include.path
            queueRunnerToken
          ];
        };
      };

      hydra-ws.serviceConfig.BindReadOnlyPaths = [
        "/run/postgresql"
        "/var/lib/hydra/build-logs"
        "/etc/hydra"
        "/etc/static/hydra"
      ];

      hydra-send-stats.serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
        # hydra-send-stats reads /proc/meminfo for its Dirty metric.
        ProcSubset = "all";
      };

      hydra-update-gc-roots.serviceConfig = {
        Type = "oneshot";
        BindPaths = [
          "/var/lib/hydra"
          config.services.hydra.gcRootsDir
        ];
        BindReadOnlyPaths = [
          "/run/postgresql"
          "/nix/store"
          "/nix/var/nix/daemon-socket"
          "/etc/nix"
          "/etc/static/nix"
        ];
      };

      hydra-check-space = {
        # Allow this confined watchdog to call the host manager's stop operation.
        environment.SYSTEMD_IN_CHROOT = "0";
        serviceConfig = {
          Type = "oneshot";
          BindReadOnlyPaths = [
            "/nix/store"
            "/run/systemd/private"
            "/run/systemd/system"
          ];
        };
      };

      hydra-compress-logs.serviceConfig = {
        Type = "oneshot";
        User = "hydra-queue-runner";
        Group = "hydra";
        BindPaths = [
          "/var/lib/hydra"
          config.services.hydra.gcRootsDir
        ];
      };

      hydra-attic-repush = {
        script = ''
          (for F in /nix/var/nix/gcroots/hydra/*; do
            echo "/nix/store/$(basename "$F")"
          done) | xargs -n10 ${lib.getExe pkgs.attic-client} push lantian || true
        '';
        serviceConfig = LT.serviceHarden // {
          Type = "oneshot";
          User = "hydra-queue-runner";
          Group = "hydra";
        };
      };
    }
  ];

  systemd.timers.hydra-attic-repush = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
