{
  pkgs,
  lib,
  dialPlan,
  dn42Prefix,
  prefixZeros,
}:
let
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
      # Menu row: "Public" (index.html), "DN42" (dn42.html), and "CardDAV"
      # (dn42.vcf). The current page is bold; the CardDAV file is always a
      # regular link since it is never the active page.
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
            {
              key = "carddav";
              label = "CardDAV";
              href = "dn42.vcf";
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
in
[
  (pkgs.writeTextDir "index.html" indexHtml)
  (pkgs.writeTextDir "dn42.html" dn42Html)
]
