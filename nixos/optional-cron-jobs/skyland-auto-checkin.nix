{
  pkgs,
  lib,
  LT,
  ...
}:
let
  py = pkgs.python3.withPackages (p: with p; [ requests ]);

  files = pkgs.stdenv.mkDerivation {
    inherit (LT.sources.skyland-auto-checkin) pname version src;

    postPatch = ''
      substituteInPlace main.py \
        --replace-fail "import notify" ""
    '';

    installPhase = ''
      mkdir -p $out/
      cp -r * $out/
    '';
  };
in
{
  systemd.services.skyland-auto-checkin = {
    environment = {
      AutoMihoyoBBS_config_path = "/var/lib/skyland-auto-checkin";
    };
    path = with pkgs; [ gitMinimal ];
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      TimeoutSec = 3600;
      StateDirectory = "skyland-auto-checkin";
      WorkingDirectory = "/var/lib/skyland-auto-checkin";
      Restart = "on-failure";
      RestartSec = "1800";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
    after = [ "network.target" ];

    script = ''
      set -euo pipefail
      export SKYLAND_TOKEN=$(cat /var/lib/skyland-auto-checkin/token.txt)
      exec ${lib.getExe py} ${files}/main.py
    '';
  };

  systemd.timers.skyland-auto-checkin = {
    wantedBy = [ "timers.target" ];
    partOf = [ "skyland-auto-checkin.service" ];
    timerConfig = {
      OnCalendar = [
        "*-*-* 02:30:00"
        "*-*-* 14:30:00"
      ];
      Persistent = true;
      RandomizedDelaySec = "4h";
      Unit = "skyland-auto-checkin.service";
    };
  };
}
