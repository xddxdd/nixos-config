{
  pkgs,
  inputs,
  config,
  LT,
  ...
}:
let
  script = pkgs.fetchurl {
    url = "https://dn42.g-load.eu/about/certificate-authority/client.sh";
    hash = "sha256-eRxfPy2agoq0fynmA82FUTbxkHo1MVCc/bK0LjxWTIM=";
  };

  csr = pkgs.writeText "csr.conf" ''
    [ req ]
    distinguished_name = req_distinguished_name
    req_extensions = req_ext

    [ req_distinguished_name ]
    countryName = CN
    countryName_default = CN
    stateOrProvinceName = Undisclosed
    stateOrProvinceName_default = Undisclosed
    localityName = Undisclosed
    localityName_default = Undisclosed
    organizationName = Lan Tian
    organizationName_default = Lan Tian
    commonName = lantian.dn42
    commonName_max = 64
    commonName_default = lantian.dn42

    [ req_ext ]
    subjectAltName = @alt_names

    [alt_names]
    DNS.1 = *.lantian.dn42
  '';
in
{
  age.secrets.dn42-certificate-token.file = inputs.secrets + "/dn42-certificate-token.age";

  systemd.services.dn42-certificate = {
    description = "Get DN42 Certificate";
    path = [
      pkgs.bash
      pkgs.curl
      pkgs.openssl
    ];
    script = ''
      set -x

      if [ ! -f "/var/lib/dn42-certificate/rsa.key" ]; then
        openssl genrsa -out /var/lib/dn42-certificate/rsa.key 4096
      fi
      if [ ! -f "/var/lib/dn42-certificate/ecc.key" ]; then
        openssl ecparam -name secp384r1 -genkey -noout -out /var/lib/dn42-certificate/ecc.key
      fi

      cat ${config.age.secrets.dn42-certificate-token.path} > token.txt

      # RSA cert
      cp /var/lib/dn42-certificate/rsa.key private.key
      openssl req -key private.key -new -out request.csr -config ${csr} -batch
      bash ${script} sign_csr lantian.dn42
      install -Dm644 --owner=root private.key /nix/persistent/sync-servers/acme/dn42-lantian.dn42-rsa/key.pem
      for F in cert.pem chain.pem fullchain.pem full.pem; do
        install -Dm644 --owner=root signed.crt /nix/persistent/sync-servers/acme/dn42-lantian.dn42-rsa/$F
      done
      rm -f private.key request.csr signed.crt

      # Kioubit's API has rate limit
      sleep 15

      # ECC cert
      cp /var/lib/dn42-certificate/ecc.key private.key
      openssl req -key private.key -new -out request.csr -config ${csr} -batch
      bash ${script} sign_csr lantian.dn42
      install -Dm644 --owner=root private.key /nix/persistent/sync-servers/acme/dn42-lantian.dn42-ecc/key.pem
      for F in cert.pem chain.pem fullchain.pem full.pem; do
        install -Dm644 --owner=root signed.crt /nix/persistent/sync-servers/acme/dn42-lantian.dn42-ecc/$F
      done
      rm -f private.key request.csr signed.crt
    '';
    serviceConfig = LT.serviceHarden // {
      Type = "oneshot";
      Restart = "no";

      AmbientCapabilities = [ "CAP_CHOWN" ];
      CapabilityBoundingSet = [ "CAP_CHOWN" ];
      ReadWritePaths = [ "/nix/persistent/sync-servers/acme" ];
      SystemCallFilter = [ ];

      StateDirectory = "dn42-certificate";
      StateDirectoryMode = "700";
      RuntimeDirectory = "dn42-certificate";
      RuntimeDirectoryMode = "700";
      WorkingDirectory = "/run/dn42-certificate";
    };
    unitConfig = {
      OnFailure = "notify-email@%n.service";
    };
  };

  systemd.timers.dn42-certificate = {
    wantedBy = [ "timers.target" ];
    partOf = [ "dn42-certificate.service" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      Unit = "dn42-certificate.service";
      RandomizedDelaySec = "1d";
    };
  };
}
