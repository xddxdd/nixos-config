{
  LT,
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  platforms = builtins.concatStringsSep "," (
    lib.uniqueStrings (config.nix.settings.extra-platforms ++ [ pkgs.stdenv.hostPlatform.system ])
  );

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
    ../postgresql.nix
    ./cancel-old-builds.nix
    ./clear-build-failures.nix
    ./watchdog.nix
  ];

  sops.secrets.attic-upload-key = {
    sopsFile = inputs.secrets + "/common/attic.yaml";
    mode = "0444";
  };

  # Force use original nix for Hydra hosts
  nix.package = lib.mkForce pkgs.nixVersions.latest;

  environment.etc."hydra/post-build".source = pkgs.writeShellScript "post-build" ''
    export PATH="${path}:$PATH"
    export HYDRA_URL="http://${LT.this.ltnet.IPv4}:${LT.portStr.Hydra}"

    jq . "$HYDRA_JSON"
    exec ${lib.getExe' py "python3"} ${./post-build.py} "$HYDRA_JSON"
  '';
  environment.etc."hydra/machines".text = ''
    localhost ${platforms} - 2 1 kvm,nixos-test,big-parallel,benchmark - -
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
    buildMachinesFiles = [ "/etc/hydra/machines" ];
    useSubstitutes = true;

    extraConfig = ''
      <runcommand>
        job = *:*:*
        command = /etc/hydra/post-build
      </runcommand>

      allow_import_from_derivation = true
    '';
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

  systemd.services.hydra-attic-repush = {
    enable = false;
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
    enable = false;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
