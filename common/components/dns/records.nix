{ pkgs, ... }:

let
  formatArg = s: if (builtins.isString s) then (pkgs.lib.escapeShellArg s) else (builtins.toString s);
  formatName = name: reverse: if reverse then "REV(${formatArg name})" else (formatArg name);

  record_meta = { ttl ? null, cloudflare ? null }:
    (pkgs.lib.optionalString (ttl != null) ", TTL(${formatArg (builtins.toString ttl)})")
    + (pkgs.lib.optionalString (cloudflare == true) ", CF_PROXY_ON")
    + (pkgs.lib.optionalString (cloudflare == false) ", CF_PROXY_OFF");

  record_1args = type: name: reverse: ttl: cloudflare:
    "${type}(${formatName name reverse}" + (record_meta { inherit ttl cloudflare; }) + ")";
  record_2args = type: name: target: reverse: ttl: cloudflare:
    "${type}(${formatName name reverse}, ${formatArg target}" + (record_meta { inherit ttl cloudflare; }) + ")";
  record_3args = type: name: arg1: target: reverse: ttl: cloudflare:
    "${type}(${formatName name reverse}, ${formatArg arg1}, ${formatArg target}" + (record_meta { inherit ttl cloudflare; }) + ")";
  record_4args = type: name: arg1: arg2: target: reverse: ttl: cloudflare:
    "${type}(${formatName name reverse}, ${formatArg arg1}, ${formatArg arg2}, ${formatArg target}" + (record_meta { inherit ttl cloudflare; }) + ")";
  record_5args = type: name: arg1: arg2: arg3: target: reverse: ttl: cloudflare:
    "${type}(${formatName name reverse}, ${formatArg arg1}, ${formatArg arg2}, ${formatArg arg3}, ${formatArg target}" + (record_meta { inherit ttl cloudflare; }) + ")";
in
rec {
  A = { name, address, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "A" name address reverse ttl cloudflare;
  AAAA = { name, address, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "AAAA" name address reverse ttl cloudflare;
  ALIAS = { name, target, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "ALIAS" name target reverse ttl cloudflare;
  CAA = { name, tag, value, reverse ? false, ttl ? null, cloudflare ? null }:
    record_3args "CAA" name tag value reverse ttl cloudflare;
  CNAME = { name, target, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "CNAME" name target reverse ttl cloudflare;
  DS = { name, keytag, algorithm, digesttype, digest, reverse ? false, ttl ? null, cloudflare ? null }:
    record_5args "DS" name keytag algorithm digesttype digest reverse ttl cloudflare;
  MX = { name, priority, target, reverse ? false, ttl ? null, cloudflare ? null }:
    record_3args "MX" name priority target reverse ttl cloudflare;
  NAMESERVER = { name, reverse ? false, ttl ? null }:
    record_1args "NAMESERVER" name reverse ttl null;
  NS = { name, target, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "NS" name target reverse ttl cloudflare;
  PTR = { name, target, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "PTR" name target reverse ttl cloudflare;
  SRV = { name, priority, weight, port, target, reverse ? false, ttl ? null, cloudflare ? null }:
    record_5args "SRV" name priority weight port target reverse ttl cloudflare;
  SSHFP = { name, algorithm, type, value, reverse ? false, ttl ? null, cloudflare ? null }:
    record_4args "SSHFP" name algorithm type value reverse ttl cloudflare;
  TLSA = { name, usage, selector, type, certificate, reverse ? false, ttl ? null, cloudflare ? null }:
    record_5args "TLSA" name usage selector type certificate reverse ttl cloudflare;
  TXT = { name, contents, reverse ? false, ttl ? null, cloudflare ? null }:
    record_2args "TXT" name contents reverse ttl cloudflare;

  SSHFP_RSA_SHA1 = { name, pubkey, reverse ? false, ttl ? null, cloudflare ? null }: SSHFP {
    inherit name reverse ttl cloudflare;
    algorithm = 1;
    type = 1;
    value = builtins.readFile (pkgs.runCommandLocal "sshfp-rsa-sha1.txt" { } ''
      echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha1sum | cut -d' ' -f1 | tr -d '\n' > $out
    '');
  };
  SSHFP_RSA_SHA256 = { name, pubkey, reverse ? false, ttl ? null, cloudflare ? null }: SSHFP {
    inherit name reverse ttl cloudflare;
    algorithm = 1;
    type = 2;
    value = builtins.readFile (pkgs.runCommandLocal "sshfp-rsa-sha256.txt" { } ''
      echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha256sum | cut -d' ' -f1 | tr -d '\n' > $out
    '');
  };
  SSHFP_ED25519_SHA1 = { name, pubkey, reverse ? false, ttl ? null, cloudflare ? null }: SSHFP {
    inherit name reverse ttl cloudflare;
    algorithm = 4;
    type = 1;
    value = builtins.readFile (pkgs.runCommandLocal "sshfp-ed25519-sha1.txt" { } ''
      echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha1sum | cut -d' ' -f1 | tr -d '\n' > $out
    '');
  };
  SSHFP_ED25519_SHA256 = { name, pubkey, reverse ? false, ttl ? null, cloudflare ? null }: SSHFP {
    inherit name reverse ttl cloudflare;
    algorithm = 4;
    type = 2;
    value = builtins.readFile (pkgs.runCommandLocal "sshfp-ed25519-sha256.txt" { } ''
      echo ${formatArg pubkey} | cut -d' ' -f2 | base64 --decode | sha256sum | cut -d' ' -f1 | tr -d '\n' > $out
    '');
  };
}
