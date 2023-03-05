{
  pkgs,
  lib,
  LT,
  config,
  utils,
  inputs,
  ...
} @ args: let
  inherit (pkgs.callPackage ./common.nix args) dialRule enumerateList prefixZeros;

  # http://www.cs.columbia.edu/~hgs/audio/codecs.html
  # https://www.speex.org/comparison/
  # https://en.wikipedia.org/wiki/Comparison_of_audio_coding_formats#Technical_details
  codecs = [
    # 48KHz
    "opus"
    "evs"

    # 32KHz
    "siren14" # 24/32/48Kbps
    "speex32" # <44.2Kbps

    # 16KHz
    "amrwb" # <23.85Kbps
    "siren7" # 16/24/32Kbps
    "speex16" # <44.2Kbps
    "g722" # 64Kbps

    # 8KHz
    "g729" # 8Kbps
    "amr" # <12.2Kbps
    "gsm-efr" # 12.2Kbps
    "gsm" # 13Kbps
    "g726" # 16/24/32/40Kbps
    "speex" # <24.6Kbps
    "ilbc" # 13.3/15.2Kbps
    "alaw" # 64Kbps
    "ulaw" # 64Kbps

    # # T.140 Text
    # # Unsupported: https://issues.asterisk.org/jira/browse/ASTERISK-28654
    # "red"
    # "t140"

    # Obsolete
    "silk24"
    "silk16"
    "silk12"
    "silk8"

    # Uncompressed
    # "slin192"
    # "slin96"
    "slin48"
    "slin44"
    "slin32"
    "slin24"
    "slin16"
    "slin12"
    "slin"
  ];
in rec {
  templates = ''
    [template-endpoint-common](!)
    type=endpoint
    allow=${builtins.concatStringsSep "," codecs}
    direct_media=no
    rtp_symmetric=yes
    force_rport=yes
    rewrite_contact=yes
    media_encryption=sdes
    media_encryption_optimistic=yes
    dtmf_mode=rfc4733
    tos_audio=ef
    cos_audio=5
    tos_video=af41
    cos_video=4
    t38_udptl=yes
    t38_udptl_ec=redundancy
    t38_udptl_nat=yes
    fax_detect=no

    [template-endpoint-local](!)
    context=src-local
    identify_by=username,auth_username

    [template-auth](!)
    type=auth
    auth_type=userpass

    [template-aor](!)
    type=aor
    max_contacts=1
    remove_existing=yes

  '';
}
