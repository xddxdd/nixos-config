{
  pkgs,
  lib,
  ...
}: let
  formatArg = s:
    if (builtins.isString s)
    then (lib.escapeShellArg s)
    else (builtins.toString s);
  formatName = name: reverse:
    if reverse
    then "REV(${formatArg name})"
    else (formatArg name);

  record = recordType: args: params: let
    configString = builtins.concatStringsSep ", " (
      [(formatName args.name args.reverse)]
      ++ (builtins.map formatArg params)
      ++ (lib.optional (args.ttl != null) "TTL(${formatArg (builtins.toString args.ttl)})")
      ++ (lib.optional (args.cloudflare == true) "CF_PROXY_ON")
      ++ (lib.optional (args.cloudflare == false) "CF_PROXY_OFF")
    );
  in ["${recordType}(${configString})"];
in {
  recordHandlers = rec {
    A = args: record "A" args [args.address];
    AAAA = args: record "AAAA" args [args.address];
    ALIAS = args: record "ALIAS" args [args.target];
    CAA = args: record "CAA" args [args.tag args.value];
    CNAME = args: record "CNAME" args [args.target];
    DS = args: record "DS" args [args.keytag args.algorithm args.digesttype args.digest];
    IGNORE = args: record "IGNORE" args [args.type];
    MX = args: record "MX" args [args.priority args.target];
    NAMESERVER = args: record "NAMESERVER" args [];
    NS = args: record "NS" args [args.target];
    PTR = args: record "PTR" args [args.target];
    SRV = args: record "SRV" args [args.priority args.weight args.port args.target];
    SSHFP = args: record "SSHFP" args [args.algorithm args.type args.value];
    TLSA = args: record "TLSA" args [args.usage args.selector args.type args.certificate];
    TXT = args: record "TXT" args [args.contents];

    SSHFP_RSA_SHA1 = {pubkey, ...} @ args:
      SSHFP (args
        // {
          algorithm = 1;
          type = 1;
          value = builtins.readFile (pkgs.runCommandLocal "sshfp-rsa-sha1.txt" {} ''
            echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha1sum | cut -d' ' -f1 | tr -d '\n' > $out
          '');
        });
    SSHFP_RSA_SHA256 = {pubkey, ...} @ args:
      SSHFP (args
        // {
          algorithm = 1;
          type = 2;
          value = builtins.readFile (pkgs.runCommandLocal "sshfp-rsa-sha256.txt" {} ''
            echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha256sum | cut -d' ' -f1 | tr -d '\n' > $out
          '');
        });
    SSHFP_ED25519_SHA1 = {pubkey, ...} @ args:
      SSHFP (args
        // {
          algorithm = 4;
          type = 1;
          value = builtins.readFile (pkgs.runCommandLocal "sshfp-ed25519-sha1.txt" {} ''
            echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha1sum | cut -d' ' -f1 | tr -d '\n' > $out
          '');
        });
    SSHFP_ED25519_SHA256 = {pubkey, ...} @ args:
      SSHFP (args
        // {
          algorithm = 4;
          type = 2;
          value = builtins.readFile (pkgs.runCommandLocal "sshfp-ed25519-sha256.txt" {} ''
            echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha256sum | cut -d' ' -f1 | tr -d '\n' > $out
          '');
        });
  };
}
