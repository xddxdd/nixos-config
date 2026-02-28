{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ./common.nix args) prefixZeros;
  inherit (pkgs.callPackage ./local-devices.nix args) destLocalDialPlan;
  inherit (pkgs.callPackage ./musics.nix args) destMusicDialPlan;
  inherit (pkgs.callPackage ./apps/astycrapper.nix args) dialAstyCrapperDescription;
  inherit (pkgs.callPackage ./apps/beverly.nix args) dialBeverlyDescription;
  inherit (pkgs.callPackage ./apps/lenny.nix args) dialLennyDescription;

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
      "0100" = "Milliwatt (1004 Hz)";
      "0101" = "Fax receiver";
      "1999" = "Ring group (1000 & 1001 & 1003)";
      "2000" = "Random between all call bots";
      "2001" = dialLennyDescription;
      "2002" = dialAstyCrapperDescription;
      "2003" = dialBeverlyDescription;
    }
    destLocalDialPlan
    destMusicDialPlan
    destConferenceDialPlan
  ];

  dialPlanRows' =
    numbers:
    lib.concatStrings (
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
        "<p>${numberLink} ${v}</p>"
      ) numbers
    );

  dialPlanDir = pkgs.writeTextDir "index.html" ''
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>lantian.pub SIP dial plan</title>
        <style>
          /*
            Josh's Custom CSS Reset
            https://www.joshwcomeau.com/css/custom-css-reset/
          */

          *, *::before, *::after {
            box-sizing: border-box;
          }

          *:not(dialog) {
            margin: 0;
          }

          @media (prefers-reduced-motion: no-preference) {
            html {
              interpolate-size: allow-keywords;
            }
          }

          body {
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
          }

          img, picture, video, canvas, svg {
            display: block;
            max-width: 100%;
          }

          input, button, textarea, select {
            font: inherit;
          }

          p, h1, h2, h3, h4, h5, h6 {
            overflow-wrap: break-word;
          }

          p {
            text-wrap: pretty;
          }
          h1, h2, h3, h4, h5, h6 {
            text-wrap: balance;
          }

          #root, #__next {
            isolation: isolate;
          }

          /* Customizations */
          body {
            margin: 10px;
          }
        </style>
      </head>
      <body>
        <details>
          <summary>sip:00XX@lantian.pub</summary>
          ${dialPlanRows' (lib.filterAttrs (k: _: lib.hasPrefix "00" k) dialPlan)}
        </details>
        ${dialPlanRows' (lib.filterAttrs (k: _: lib.hasPrefix "01" k) dialPlan)}
        <details>
          <summary>sip:02XX@lantian.pub</summary>
          ${dialPlanRows' (lib.filterAttrs (k: _: lib.hasPrefix "02" k) dialPlan)}
        </details>
        ${dialPlanRows' (lib.filterAttrs (k: _: !(lib.hasPrefix "0" k)) dialPlan)}
      </body>
    </html>
  '';
in
{
  lantian.nginxVhosts."sip.lantian.pub" = {
    root = dialPlanDir;
    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
