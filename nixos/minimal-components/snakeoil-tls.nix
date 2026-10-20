{
  config,
  lib,
  pkgs,
  ...
}:
{
  lantian.secrets.tls-snakeoil = {
    command = ''
      ${lib.getExe pkgs.openssl} req -x509 -newkey rsa:3072 -noenc -sha256 -days 3650 \
        -subj ${lib.escapeShellArg "/CN=${config.networking.hostName}"} \
        -addext ${lib.escapeShellArg "subjectAltName=DNS:${config.networking.hostName},DNS:localhost,IP:127.0.0.1,IP:::1"} \
        -keyout private.key -out certificate.pem
      # A single atomically published PEM keeps the private key and certificate
      # paired even when generation is interrupted. OpenSSL/nginx accept both.
      ${pkgs.coreutils}/bin/cat private.key certificate.pem
    '';
    group = if config.services.nginx.enable then config.services.nginx.group else "root";
    mode = if config.services.nginx.enable then "0640" else "0600";
    audit = false;
  };
}
