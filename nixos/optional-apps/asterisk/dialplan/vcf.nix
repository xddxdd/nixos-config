{
  pkgs,
  lib,
  dialPlan,
  dn42Prefix,
  prefixZeros,
}:
let
  # Escape vCard 3.0 text-value special characters (RFC 2426):
  # backslash, semicolon, comma, newline.
  escapeVcard = s: lib.replaceStrings [ "\\" ";" "," "\n" ] [ "\\\\" "\\;" "\\," "\\n" ] s;

  # Strip HTML tags so contact names stay plain text. Some bot descriptions
  # embed <a>...</a> links (rendered on the HTML pages), which would show up
  # as raw markup inside a vCard FN/N.
  stripHtml =
    s: builtins.concatStringsSep "" (lib.filter builtins.isString (builtins.split "<[^>]*>" s));

  # One vCard 3.0 contact per DN42 number, importable into CardDAV clients.
  # CRLF line endings per RFC 2426; each contact gets a unique UID derived
  # from its DN42 number so CardDAV servers can address them individually.
  dn42VcfContent =
    lib.concatStringsSep "\r\n" (
      lib.mapAttrsToList (
        n: v:
        let
          number = prefixZeros 4 n;
          name = escapeVcard (stripHtml v);
        in
        lib.concatStringsSep "\r\n" [
          "BEGIN:VCARD"
          "VERSION:3.0"
          "UID:${dn42Prefix}${number}@lantian.dn42"
          "FN:${name}"
          "N:${name};;;;"
          "TEL;TYPE=VOICE:${dn42Prefix}${number}"
          "END:VCARD"
        ]
      ) dialPlan
    )
    + "\r\n";
in
[
  (pkgs.writeTextDir "dn42.vcf" dn42VcfContent)
]
