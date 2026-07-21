{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ../common.nix args) prefixZeros;
  inherit (pkgs.callPackage ../local-devices.nix args) destLocalDialPlan;
  inherit (pkgs.callPackage ../musics.nix args) destMusicDialPlan;
  inherit (pkgs.callPackage ../apps/anti-fooling.nix args) dialAntiFoolingDescription;
  inherit (pkgs.callPackage ../apps/astycrapper.nix args) dialAstyCrapperDescription;
  inherit (pkgs.callPackage ../apps/beverly.nix args) dialBeverlyDescription;
  inherit (pkgs.callPackage ../apps/lenny.nix args) dialLennyDescription;
  inherit (pkgs.callPackage ../apps/never-gonna.nix args) dialNeverGonnaDescription;

  destConferenceDialPlan = builtins.listToAttrs (
    lib.genList (
      i:
      let
        n = if i < 10 then "0${builtins.toString i}" else builtins.toString i;
      in
      lib.nameValuePair "02${n}" "Conference room #${n}"
    ) 100
  );

  dialPlan = lib.mergeAttrsList [
    {
      "0000" = "Random between all music playback";
      "1900" = "Milliwatt (1004 Hz)";
      "1901" = "Fax receiver";
      "1902" = "SMS auto reply";
      "1999" = "Ring group (1000 & 1001 & 1003)";
      "2000" = "Random between all call bots";
      "2001" = dialLennyDescription;
      "2002" = dialAstyCrapperDescription;
      "2003" = dialBeverlyDescription;
      "2004" = dialNeverGonnaDescription;
      "2005" = dialAntiFoolingDescription;
    }
    destLocalDialPlan
    destMusicDialPlan
    destConferenceDialPlan
  ];

  # DN42 phone numbers prepend "+04242547" to the 4-digit local extension,
  # matching the +04242547XXXX inbound rule in extensions.conf
  # (+04242547 + 1234 = +042425471234).
  dn42Prefix = "+04242547";

  # Generate the HTML pages and the CardDAV vCard file, then merge everything
  # into a single directory served by the sip.lantian.pub vhost.
  htmlFiles = pkgs.callPackage ./html.nix {
    inherit dialPlan dn42Prefix prefixZeros;
  };
  vcfFiles = pkgs.callPackage ./vcf.nix {
    inherit dialPlan dn42Prefix prefixZeros;
  };

  dialPlanDir = pkgs.symlinkJoin {
    name = "sip-dial-plan";
    paths = htmlFiles ++ vcfFiles;
  };
in
{
  lantian.nginxVhosts."sip.lantian.pub" = {
    root = dialPlanDir;
    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
