{
  LT,
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  py = pkgs.python3.withPackages (
    ps: with ps; [
      pydantic
      requests
    ]
  );
  path = lib.makeBinPath [
    pkgs.gitMinimal
    pkgs.jq
    pkgs.attic-client
  ];
in
{
  imports = [
    ../nix-distributed.nix
    ../postgresql.nix
    ./cancel-old-builds.nix
    ./clear-build-failures.nix
  ];

  sops.secrets.attic-upload-key = {
    sopsFile = inputs.secrets + "/common/attic.yaml";
    mode = "0444";
  };
  # Read by hydra-server at startup, so it must be readable by the hydra user
  sops.secrets.dex-hydra-secret = {
    sopsFile = inputs.secrets + "/common/dex.yaml";
    mode = "0440";
    owner = "hydra";
    group = "hydra";
  };

  sops.secrets.hydra-ssh-privkey = {
    sopsFile = inputs.secrets + "/hydra.yaml";
    mode = "0440";
    owner = "hydra";
    group = "hydra";
  };
  # Shared by the queue runner (tokenPaths) and hydra-builder (authorizationFile);
  # both services run under group hydra
  sops.secrets.hydra-queue-runner-token = {
    sopsFile = inputs.secrets + "/hydra.yaml";
    mode = "0440";
    owner = "hydra";
    group = "hydra";
  };

  lantian.nix-distributed.sshKeyPath = config.sops.secrets.hydra-ssh-privkey.path;

  # Force use original nix for Hydra hosts
  nix.package = lib.mkForce pkgs.nixVersions.latest;

  environment.etc."hydra/post-build".source = pkgs.writeShellScript "post-build" ''
    export PATH="${path}:$PATH"
    export HYDRA_URL="http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra.WebUI}"

    jq . "$HYDRA_JSON"
    exec ${lib.getExe' py "python3"} ${./post-build.py} "$HYDRA_JSON"
  '';

  services.hydra = {
    enable = true;
    # FIXME: disable failing checks
    package = pkgs.hydra.overrideAttrs (old: {
      doCheck = false;
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
        tokenPaths = [ config.sops.secrets.hydra-queue-runner-token.path ];
      };
    };

    extraConfig = ''
      local_auth_enabled = 0

      <runcommand>
        job = *:*:*
        command = /etc/hydra/post-build
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
    '';
  };

  services.hydra-builder = {
    enable = true;
    authorizationFile = config.sops.secrets.hydra-queue-runner-token.path;
    queueRunnerAddr = "http://127.0.0.1:${LT.portStr.Hydra.QueueRunnerGRPC}";
  };

  systemd.services.hydra-notify = {
    preStart = ''
      if [ ! -f "$HOME/.config/attic/config.toml" ]; then
        ${lib.getExe pkgs.attic-client} login --set-default lantian \
          https://attic.colocrossing.xuyh0120.win \
          $(cat ${config.sops.secrets.attic-upload-key.path})
      fi
    '';
  };

  systemd.services.hydra-queue-runner.serviceConfig = {
    OOMScoreAdjust = "1000";
  };

  systemd.services.hydra-attic-repush = {
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

  systemd.timers.hydra-attic-repush = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
