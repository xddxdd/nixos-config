{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ./common.nix args) dialRule;

  localNumbers = [
    "1000" # Laptop (Linphone)
    "1001" # Android Phone (Linphone)
    "1002" # Bria
    "1003" # Grandstream HT801
    "1004" # iPhone (Linphone)
  ];
in
{
  localDevices = lib.concatMapStringsSep "\n" (number: ''
    [${number}](template-endpoint-local)
    auth=${number}
    aors=${number}
    callerid=Lan Tian <${number}>

    [${number}](template-aor)
  '') localNumbers;

  destLocal = lib.concatMapStringsSep "\n" (
    number: dialRule number [ "Dial(PJSIP/${number})" ]
  ) localNumbers;

  destLocalDialPlan = lib.genAttrs localNumbers (n: "SIP user");
}
