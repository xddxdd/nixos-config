{ pkgs, lib, LT, config, utils, inputs, ... }@args:

let
  homeDir = "/nix/persistent/sync-servers/acme.sh";
in
{
  environment.systemPackages = [
    (pkgs.stdenv.mkDerivation {
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
    })
  ];
}
