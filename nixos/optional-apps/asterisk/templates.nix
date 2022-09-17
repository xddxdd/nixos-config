{ config, pkgs, lib, ... }:

let
  LT = import ../../../helpers { inherit config pkgs; };

  inherit (pkgs.callPackage ./common.nix { }) dialRule enumerateList prefixZeros;
in
rec {
  templates = ''
    [template-endpoint-common](!)
    type=endpoint
    allow=opus,g722,alaw,ulaw,speex32,speex16,g729,g726,ilbc,speex
    direct_media=no
    rtp_symmetric=yes
    force_rport=yes
    rewrite_contact=yes
    media_encryption=sdes
    media_encryption_optimistic=yes
    tos_audio=ef
    cos_audio=5
    tos_video=af41
    cos_video=4

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
