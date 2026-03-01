{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ./common.nix args) dialRule;

  peers = {
    # keep-sorted start
    "0298" = "[fdfa:6ded:ae4::58e]";
    "3999" = "172.22.144.80";
    # keep-sorted end
  };
in
{
  peers = lib.concatMapAttrsStringSep "\n" (k: v: ''
    [peer-${k}](template-endpoint-peer)
    aors=peer-${k}
    identify_by=ip

    [peer-${k}](template-aor)
    contact=sip:${v}:5060

    [peer-${k}]
    type=identify
    endpoint=peer-${k}
    match=${v}
  '') peers;

  destPeers = lib.concatMapAttrsStringSep "\n" (
    k: v: dialRule "4240${k}." [ "Dial(PJSIP/\${EXTEN}@peer-${k})" ]
  ) peers;
}
