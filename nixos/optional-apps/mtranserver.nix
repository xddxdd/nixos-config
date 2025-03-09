{
  LT,
  config,
  pkgs,
  ...
}:
let
  models = pkgs.fetchgit {
    url = "https://github.com/mozilla/firefox-translations-models.git";
    rev = "250530e63f82e032e2aad483ce23f8b1a7635c08";
    fetchLFS = true;
    sha256 = "sha256-U51zK5VVTNjx6att+78kUrDvWL5S3ZY3eEXX6p+uPX8=";
  };

  enabledModels = pkgs.runCommand "mtranserver-models" { } ''
    mkdir -p $out
    for MODEL in enzh; do
      cp -r ${models}/models/dev/$MODEL $out/$MODEL || cp -r ${models}/models/prod/$MODEL $out/$MODEL
    done
    chmod -R +w $out
    ${pkgs.gzip}/bin/gunzip -r $out
  '';
in
{
  virtualisation.oci-containers.containers.mtranserver = {
    extraOptions = [
      "--pull=always"
    ];
    ports = [
      "127.0.0.1:${LT.portStr.MTranServer}:8989"
    ];
    volumes = [
      "${enabledModels}:/app/models:ro"
    ];
    image = "ghcr.io/xxnuo/mtranserver:latest";
  };

  lantian.nginxVhosts."mtranserver.${config.networking.hostName}.xuyh0120.win" = {
    locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.MTranServer}";
        proxyNoTimeout = true;
      };
    };

    sslCertificate = "${config.networking.hostName}.xuyh0120.win_ecc";
    noIndex.enable = true;
  };
}
