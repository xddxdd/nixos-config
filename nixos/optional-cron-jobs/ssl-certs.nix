{
  pkgs,
  LT,
  ...
}:
let
  homeDir = "/nix/persistent/sync-servers/acme.sh";

  acme-sh-wrapped = pkgs.stdenv.mkDerivation {
    name = "acme-sh";
    version = "0.0.1";

    phases = [ "installPhase" ];
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      makeWrapper "${pkgs.acme-sh}/bin/acme.sh" "$out/bin/acme.sh" \
        --argv0 "acme.sh" \
        --run "rm -rf ${homeDir}/deploy" \
        --run "ln -sf ${pkgs.acme-sh}/libexec/deploy ${homeDir}/deploy" \
        --run "rm -rf ${homeDir}/dnsapi" \
        --run "ln -sf ${pkgs.acme-sh}/libexec/dnsapi ${homeDir}/dnsapi" \
        --run "rm -rf ${homeDir}/notify" \
        --run "ln -sf ${pkgs.acme-sh}/libexec/notify ${homeDir}/notify" \
        --add-flags "--home ${homeDir}" \
        --add-flags "--auto-upgrade 0"
    '';
  };
in
{
  environment.systemPackages = [
    acme-sh-wrapped
  ];

  systemd.services.ssl-certs = {
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      ReadWritePaths = [ "/nix/persistent/sync-servers/acme.sh" ];
    };
    unitConfig.OnFailure = "notify-email-fail@%n.service";
    path = [ acme-sh-wrapped ];
    script = ''
      acme.sh --cron
    '';
  };

  systemd.timers.ssl-certs = {
    wantedBy = [ "timers.target" ];
    partOf = [ "ssl-certs.service" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1h";
      Unit = "ssl-certs.service";
    };
  };
}
