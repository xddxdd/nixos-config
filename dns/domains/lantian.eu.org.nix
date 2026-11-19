{
  config,
  lib,
  pkgs,
  ...
}:
let
  gpgKeysDir = ../../helpers/gpg-keys;
  # builtins.path copies each key to its own store path; a plain
  # "${gpgKeysDir}/${name}" string is a sub-path of the flake source and would
  # not be mounted into the build sandbox
  gpgKeys = lib.mapAttrsToList (
    n: _:
    builtins.path {
      path = gpgKeysDir + "/${n}";
      name = n;
    }
  ) (builtins.readDir gpgKeysDir);

  # DNSControl takes the key as hex or base64, and deSEC stores it base64-encoded
  keyBase64 =
    key:
    builtins.readFile (
      pkgs.runCommandLocal "gpg-key-base64" { } ''
        base64 --wrap=0 < ${key} > $out
      ''
    );

  # Bunny DNS cannot serve OPENPGPKEY records, so the keys live here and
  # lantian.pub points its _openpgpkey names at them with CNAMEs
  openPGPKeyRecords = lib.map (key: {
    recordType = "OPENPGPKEY";
    name = "${config.common.records.openPGPKeyLabel "lantian@lantian.pub"}.pgp";
    publicKey = keyBase64 key;
    ttl = "1h";
  }) gpgKeys;
in
{
  domains = [
    rec {
      domain = "lantian.eu.org";
      registrar = "none";
      providers = [ "desec" ];
      records = lib.flatten [
        (config.common.apexRecords "${domain}.")
        (config.common.hostRecs.Normal "${domain}.")
        (config.common.hostRecs.SSHFP "${domain}.")
        config.common.records.Libravatar
        config.common.records.SIP
        openPGPKeyRecords

        (config.common.hostRecs.LTNet "ltnet.${domain}.")
        (config.common.hostRecs.DN42 "dn42.${domain}.")
        (config.common.hostRecs.NeoNetwork "neo.${domain}.")

        {
          recordType = "AAAA";
          name = "manosaba";
          address = "2001:470:8c19::14";
        }
      ];
    }
  ];
}
