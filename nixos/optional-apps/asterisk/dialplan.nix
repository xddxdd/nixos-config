{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ./common.nix args) prefixZeros;
  inherit (pkgs.callPackage ./local-devices.nix args) destLocalDialPlan;
  inherit (pkgs.callPackage ./musics.nix args) destMusicDialPlan;
  inherit (pkgs.callPackage ./apps/astycrapper.nix args) dialAstyCrapperDescription;
  inherit (pkgs.callPackage ./apps/beverly.nix args) dialBeverlyDescription;
  inherit (pkgs.callPackage ./apps/lenny.nix args) dialLennyDescription;

  dialPlan = lib.mergeAttrsList [
    {
      "0000" = "Random between all music playback";
      "0100" = "Milliwatt (1004 Hz)";
      "0101" = "Fax receiver";
      "02XX" = "Conference room XX";
      "1999" = "Ring group (1000 & 1001 & 1003)";
      "2000" = "Random between all call bots";
      "2001" = dialLennyDescription;
      "2002" = dialAstyCrapperDescription;
      "2003" = dialBeverlyDescription;
    }
    destLocalDialPlan
    destMusicDialPlan
  ];

  dialPlanRows = lib.concatStrings (
    lib.mapAttrsToList (
      n: v:
      let
        number = prefixZeros 4 n;
        numberLink =
          if builtins.match "[[:digit:]]+" number != null then
            "<a href=\"sip:${number}@lantian.pub\">sip:${number}@lantian.pub</a>"
          else
            "sip:${number}@lantian.pub";
      in
      "<tr><td>${numberLink}</td><td>${v}</td></tr>"
    ) dialPlan
  );

  dialPlanDir = pkgs.writeTextDir "index.html" ''
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>lantian.pub SIP dial plan</title>
      </head>
      <body>
        <table>
          <thead>
            <tr><td>Number</td><td>Description</td></tr>
          </thead>
          <tbody>${dialPlanRows}</tbody>
        </table>
      </body>
    </html>
  '';
in
{
  lantian.nginxVhosts."sip.lantian.pub" = {
    root = dialPlanDir;
    sslCertificate = "lets-encrypt-lantian.pub";
    noIndex.enable = true;
  };
}
