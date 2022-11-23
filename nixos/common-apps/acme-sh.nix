{ pkgs, lib, config, utils, inputs, ... }@args:

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
          --add-flags "--home /nix/persistent/sync-servers/acme.sh" \
          --add-flags "--auto-upgrade 0"
      '';
    })
  ];
}
