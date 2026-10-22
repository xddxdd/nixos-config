{
  pkgs,
  lib,
  LT,
  inputs,
  config,
  ...
}:
let
  hardenArgs = (import ../../../helpers/fn/service-harden.nix { inherit lib; }).serviceHardenArgs;
in
{
  sops.secrets.adsb-flightradar24-key = {
    sopsFile = inputs.secrets + "/adsb.yaml";
    owner = "fr24";
    group = "fr24";
  };
  sops.secrets.adsb-flightradar24-uat-key = {
    sopsFile = inputs.secrets + "/adsb.yaml";
    owner = "fr24";
    group = "fr24";
  };

  environment.systemPackages = [ pkgs.nur-xddxdd.fr24feed ];

  systemd.services.fr24feed = {
    description = "Flightradar24 Feeder";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${lib.getExe pkgs.nur-xddxdd.fr24feed} \
        --monitor-file=/run/fr24feed/decoder.txt \
        --fr24key=$(cat ${config.sops.secrets.adsb-flightradar24-key.path}) \
        --bs=no \
        --raw=no \
        --mlat=no \
        --mlat-without-gps=no \
        --receiver=beast-tcp \
        --host=${LT.constants.localHost.IPv4}:${LT.portStr.ADSB.BeastOutput}
    '';

    serviceConfig = LT.serviceHarden // {
      User = "fr24";
      Group = "fr24";

      RuntimeDirectory = "fr24feed";

      # Flightradar24 key is a sops secret outside the confinement chroot
      BindReadOnlyPaths = [ config.sops.secrets.adsb-flightradar24-key.path ];

      # fr24feed is an FHS-env wrapper on bubblewrap: verified live on lt-rpi4
      # that it needs user/mount namespaces, mount+capset syscalls, and
      # unrestricted /proc (for /proc/sys/kernel/overflowuid)
      ProcSubset = "all";
      RestrictNamespaces = [
        "user"
        "mnt"
        "pid"
      ];
      SystemCallFilter = hardenArgs.SystemCallFilter ++ [ "@mount capset" ];

      Restart = "always";
      RestartSec = "5";
    };
  };
  lantian.harden.fr24feed = true;

  systemd.services.fr24uat-feed = {
    description = "Flightradar24 UAT Feeder";
    after = [
      "network.target"
      "dump978.service"
    ];
    requires = [
      "dump978.service"
    ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      exec ${lib.getExe pkgs.nur-xddxdd.fr24feed} \
        --monitor-file=/run/fr24uat-feed/decoder.txt \
        --fr24key=$(cat ${config.sops.secrets.adsb-flightradar24-uat-key.path}) \
        --http-listen-port=8755 \
        --unit=fr24uat-feed \
        --receiver=uat-tcp \
        --uat-port="${LT.portStr.ADSB.RawOutput978}"
    '';

    serviceConfig = LT.serviceHarden // {
      User = "fr24";
      Group = "fr24";

      RuntimeDirectory = "fr24uat-feed";

      # Flightradar24 key is a sops secret outside the confinement chroot
      BindReadOnlyPaths = [ config.sops.secrets.adsb-flightradar24-uat-key.path ];

      # Same bwrap requirements as fr24feed
      ProcSubset = "all";
      RestrictNamespaces = [
        "user"
        "mnt"
        "pid"
      ];
      SystemCallFilter = hardenArgs.SystemCallFilter ++ [ "@mount capset" ];

      Restart = "always";
      RestartSec = "5";
    };
  };
  lantian.harden.fr24uat-feed = true;

  users.users.fr24 = {
    group = "fr24";
    isSystemUser = true;
  };
  users.groups.fr24 = { };
}
