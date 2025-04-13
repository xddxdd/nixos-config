{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ./common.nix args) prefixZeros;
  inherit (pkgs.callPackage ./local-devices.nix args) destLocalDialPlan;
  inherit (pkgs.callPackage ./musics.nix args) destMusicDialPlan;

  dialPlan = lib.mergeAttrsList [
    {
      "0100" = "Milliwatt (1004 Hz)";
      "0101" = "Fax receiver";
      "02XX" = "Conference room XX";
      "1999" = "Ring group (1000 & 1001 & 1003)";
      "2000" = "Random between all call bots";
      "2001" = "Lenny";
      "2002" =
        "Jordan (Asty-crapper, https://web.archive.org/web/20110517174427/http://www.linuxsystems.com.au/astycrapper/)";
      "2003" = "Beverly (https://worldofprankcalls.com/beverly/)";
    }
    destLocalDialPlan
    destMusicDialPlan
  ];

  dialPlanDir = pkgs.writeTextDir "index.txt" (
    lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "${prefixZeros 4 n}: ${v}") dialPlan)
  );
in
{
  lantian.nginxVhosts."sip.lantian.pub" = {
    root = dialPlanDir;
    locations."/".index = "index.txt";
    sslCertificate = "lantian.pub_ecc";
    noIndex.enable = true;
  };
}
