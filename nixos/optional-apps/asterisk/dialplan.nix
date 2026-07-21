{ pkgs, lib, ... }@args:
let
  inherit (pkgs.callPackage ./common.nix args) prefixZeros;
  inherit (pkgs.callPackage ./local-devices.nix args) destLocalDialPlan;
  inherit (pkgs.callPackage ./musics.nix args) destMusicDialPlan;
  inherit (pkgs.callPackage ./apps/anti-fooling.nix args) dialAntiFoolingDescription;
  inherit (pkgs.callPackage ./apps/astycrapper.nix args) dialAstyCrapperDescription;
  inherit (pkgs.callPackage ./apps/beverly.nix args) dialBeverlyDescription;
  inherit (pkgs.callPackage ./apps/lenny.nix args) dialLennyDescription;
  inherit (pkgs.callPackage ./apps/never-gonna.nix args) dialNeverGonnaDescription;

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

  # DN42 phone numbers prepend this 8-digit prefix to the 4-digit local
  # extension, matching the 04242547XXXX inbound rule in extensions.conf
  # (04242547 + 1234 = 042425471234).
  dn42Prefix = "04242547";

  # Build a dial plan page. linkGen turns a 4-digit number into a clickable
  # link, summaryGen produces the <summary> text for a 2-digit group prefix.
  makeHtml =
    {
      title,
      current,
      linkGen,
      summaryGen,
    }:
    let
      rows =
        numbers:
        lib.concatStrings (
          lib.mapAttrsToList (
            n: v:
            let
              number = prefixZeros 4 n;
            in
            "<p>${linkGen number} ${v}</p>"
          ) numbers
        );
      # Menu row: "Public" (index.html) and "DN42" (dn42.html).
      # The current page is bold, the other is a regular link.
      menu = lib.concatStringsSep " " (
        map
          (
            item:
            if item.key == current then
              "<strong>${item.label}</strong>"
            else
              "<a href=\"${item.href}\">${item.label}</a>"
          )
          [
            {
              key = "public";
              label = "Public";
              href = "index.html";
            }
            {
              key = "dn42";
              label = "DN42";
              href = "dn42.html";
            }
          ]
      );
    in
    ''
      <!doctype html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>${title}</title>
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
          <nav>${menu}</nav>
          <details>
            <summary>${summaryGen "00"}</summary>
            ${rows (lib.filterAttrs (k: _: lib.hasPrefix "00" k) dialPlan)}
          </details>
          <details>
            <summary>${summaryGen "02"}</summary>
            ${rows (lib.filterAttrs (k: _: lib.hasPrefix "02" k) dialPlan)}
          </details>
          ${rows (lib.filterAttrs (k: _: !(lib.hasPrefix "0" k)) dialPlan)}
        </body>
      </html>
    '';

  indexHtml = makeHtml {
    title = "lantian.pub SIP dial plan";
    current = "public";
    linkGen =
      number:
      if builtins.match "[[:digit:]]+" number != null then
        "<a href=\"sip:${number}@lantian.pub\">sip:${number}@lantian.pub</a>"
      else
        "sip:${number}@lantian.pub";
    summaryGen = prefix: "sip:${prefix}XX@lantian.pub";
  };

  dn42Html = makeHtml {
    title = "lantian.dn42 phone dial plan";
    current = "dn42";
    linkGen =
      number:
      if builtins.match "[[:digit:]]+" number != null then
        "<a href=\"tel:${dn42Prefix}${number}\">${dn42Prefix}${number}</a>"
      else
        "${dn42Prefix}${number}";
    summaryGen = prefix: "${dn42Prefix}${prefix}XX";
  };

  dialPlanDir = pkgs.symlinkJoin {
    name = "sip-dial-plan";
    paths = [
      (pkgs.writeTextDir "index.html" indexHtml)
      (pkgs.writeTextDir "dn42.html" dn42Html)
    ];
  };
in
{
  lantian.nginxVhosts."sip.lantian.pub" = {
    root = dialPlanDir;
    sslCertificate = "zerossl-lantian.pub";
    noIndex.enable = true;
  };
}
