{
  pkgs,
  lib,
  LT,
  ...
}:
let
  homeDir = "/nix/persistent/sync-servers/acme.sh";

  subdomains = builtins.concatStringsSep " " (lib.mapAttrsToList (n: _v: n) LT.hosts);

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

  acme-sh-auto = pkgs.writeShellScriptBin "acme.sh-auto" ''
    set -x

    for SUBDOMAIN in ${subdomains}; do
      if [ ! -f "${homeDir}/$SUBDOMAIN.xuyh0120.win/$SUBDOMAIN.xuyh0120.win.cer" ]; then
        acme.sh --issue --dns dns_gcore -d $SUBDOMAIN.xuyh0120.win -d \*.$SUBDOMAIN.xuyh0120.win -k 2048
      fi
      if [ ! -f "${homeDir}/$SUBDOMAIN.xuyh0120.win_ecc/$SUBDOMAIN.xuyh0120.win.cer" ]; then
        acme.sh --issue --dns dns_gcore -d $SUBDOMAIN.xuyh0120.win -d \*.$SUBDOMAIN.xuyh0120.win -k ec-256
      fi
    done

    find ${homeDir}/ -type f -exec chmod 644 -- {} +
  '';
in
{
  environment.systemPackages = [
    acme-sh-auto
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
      ${acme-sh-auto}/bin/acme.sh-auto
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
