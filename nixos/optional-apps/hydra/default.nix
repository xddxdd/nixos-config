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
    ./watchdog.nix
  ];

  sops.secrets.attic-upload-key = {
    sopsFile = inputs.secrets + "/common/attic.yaml";
    mode = "0444";
  };
  sops.secrets.hydra-ssh-privkey = {
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
    export HYDRA_URL="http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra}"

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
    port = LT.port.Hydra;
    buildMachinesFiles = [ "/etc/nix/machines-with-localhost" ];
    useSubstitutes = true;

    maxServers = 10;
    maxSpareServers = 2;
    minSpareServers = 1;

    extraConfig = ''
      <runcommand>
        job = *:*:*
        command = /etc/hydra/post-build
      </runcommand>

      allow_import_from_derivation = true
    '';
  };

  # Disable SQLite VACUUM to avoid database lockup
  services.fast-nix-gc.noVacuum = true;

  systemd.services.hydra-notify = {
    preStart = ''
      if [ ! -f "$HOME/.config/attic/config.toml" ]; then
        ${lib.getExe pkgs.attic-client} login --set-default lantian \
          https://attic.colocrossing.xuyh0120.win \
          $(cat ${config.sops.secrets.attic-upload-key.path})
      fi
    '';
  };

  systemd.services.hydra-attic-repush = {
    script = ''
      for F in /nix/var/nix/gcroots/hydra/*; do
        STORE_PATH="/nix/store/$(basename "$F")"
        ${lib.getExe pkgs.attic-client} push lantian "$STORE_PATH" || true
      done
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

  systemd.services.hydra-kill-idle-db-conn = {
    serviceConfig = LT.serviceHarden // {
      ExecStart = ''${lib.getExe' config.services.postgresql.package "psql"} -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'hydra' AND pid <> pg_backend_pid() AND state = 'idle' AND state_change < current_timestamp - INTERVAL '10' MINUTE;"'';
      Type = "oneshot";
      User = "hydra";
      Group = "hydra";
    };
  };

  systemd.timers.hydra-kill-idle-db-conn = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/10";
      Persistent = true;
      RandomizedDelaySec = "10min";
    };
  };
}
