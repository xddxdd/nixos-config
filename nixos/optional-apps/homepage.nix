{
  LT,
  lib,
  config,
  pkgs,
  ...
}:
let
  thisHost = config.networking.hostName;

  # Vhosts defined on the current host (read locally to avoid self-recursion),
  # plus vhosts from every other host in the flake. Only the cheap option fields
  # (serverName, serverAliases, listenHTTPS.enable) are read, so this does not
  # force the heavy nginx config generation of those hosts.
  ownVhosts = config.lantian.nginxVhosts;
  otherConfigs = lib.filterAttrs (n: _: n != thisHost) LT.self.nixosConfigurations;

  # Each entry is tagged with the host it originated from, so .localhost and
  # per-host top-level aliases can be filtered relative to their source host.
  entriesFrom =
    hostName: vhosts:
    lib.flatten (
      lib.mapAttrsToList (
        _: vhost:
        let
          scheme = if vhost.listenHTTPS.enable then "https" else "http";
        in
        {
          inherit scheme;
          name = vhost.serverName;
          src = hostName;
        }
      ) vhosts
    );

  allEntries =
    (entriesFrom thisHost ownVhosts)
    ++ lib.flatten (
      lib.mapAttrsToList (
        n: v: entriesFrom n (lib.attrByPath [ "lantian" "nginxVhosts" ] { } v.config)
      ) otherConfigs
    );

  # Keep an entry when:
  #  - it is not an internal catch-all (serverName starting with "_"),
  #  - it is not a wildcard vhost (name containing "*"),
  #  - it ends with .lantian.pub, .xuyh0120.win, or .localhost,
  #  - .localhost entries are only kept from the current host (they are per-host),
  #  - it is not the redundant per-host top-level alias <host>.lantian.pub or
  #    <host>.xuyh0120.win (subdomains like <svc>.<host>.<domain> are kept).
  keep =
    e:
    let
      inherit (e) name src;
      suffixOk =
        lib.hasSuffix ".lantian.pub" name
        || lib.hasSuffix ".xuyh0120.win" name
        || lib.hasSuffix ".localhost" name;
      localhostOk = !lib.hasSuffix ".localhost" name || src == thisHost;
      hostAliasOk = !(name == "${src}.lantian.pub" || name == "${src}.xuyh0120.win");
    in
    (!lib.hasPrefix "_" name)
    && !lib.hasInfix "*" name
    && !lib.hasPrefix "www." name
    && suffixOk
    && localhostOk
    && hostAliasOk;

  # Split a hostname into the subdomain label to highlight and the trailing
  # domain suffix to dim. The longest matching suffix wins so that a per-host
  # suffix like ".<host>.xuyh0120.win" dims more than the bare ".xuyh0120.win".
  splitName =
    name: src:
    let
      candidates = [
        ".${src}.lantian.pub"
        ".${src}.xuyh0120.win"
        ".lantian.pub"
        ".xuyh0120.win"
        ".localhost"
        "lantian.pub"
        "xuyh0120.win"
      ];
      matched = builtins.foldl' (
        acc: c:
        if lib.hasSuffix c name && (acc == null || builtins.stringLength c > acc.len) then
          {
            inherit c;
            len = builtins.stringLength c;
          }
        else
          acc
      ) null candidates;
      suffix = if matched == null then "" else matched.c;
      hl = builtins.substring 0 (builtins.stringLength name - builtins.stringLength suffix) name;
    in
    {
      highlight = hl;
      inherit suffix;
    };

  linkRecords =
    let
      records = builtins.map (
        e:
        let
          parts = splitName e.name e.src;
        in
        {
          url = "${e.scheme}://${e.name}";
          proto = "${e.scheme}://";
          inherit (parts) highlight suffix;
        }
      ) (builtins.filter keep allEntries);
      dedup = acc: r: if builtins.any (x: x.url == r.url) acc then acc else acc ++ [ r ];
    in
    builtins.sort (a: b: a.url < b.url) (builtins.foldl' dedup [ ] records);

  linksHtml = lib.concatMapStringsSep "\n" (
    r: ''<li><a href="${r.url}">${r.proto}<span class="hl">${r.highlight}</span>${r.suffix}</a></li>''
  ) linkRecords;

  html = ''
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Homepage</title>
    <style>
    :root { color-scheme: light dark; }
    body {
      font-family: system-ui, sans-serif;
      max-width: 720px;
      margin: 1rem auto;
      padding: 0 1rem;
    }
    h1 { font-size: 1.25rem; }
    ul { list-style: none; padding: 0; }
    li { padding: 0.15rem 0; }
    a { text-decoration: none; }
    a:hover { text-decoration: underline; }
    @media (prefers-color-scheme: dark) {
      body { background: #121212; color: #e0e0e0; }
      a { color: #6b6b6b; }
      .hl { color: #8ab4f8; }
    }
    @media (prefers-color-scheme: light) {
      body { background: #ffffff; color: #111111; }
      a { color: #888888; }
      .hl { color: #1a73e8; }
    }
    </style>
    </head>
    <body>
    <h1>Homepage</h1>
    <ul>
    ${linksHtml}
    </ul>
    </body>
    </html>
  '';

  homepagePkg = pkgs.writeTextDir "index.html" html;
in
{
  lantian.nginxVhosts."homepage.localhost" = {
    listenHTTP.enable = true;
    listenHTTPS.enable = false;
    root = homepagePkg;
    enableCommonLocationOptions = false;
    accessibleBy = "localhost";
  };

  # Point both installed browsers at the local navigation page.
  programs.firefox.policies.Homepage.URL = lib.mkForce "http://homepage.localhost";
  programs.chromium.extraOpts.HomepageLocation = lib.mkForce "http://homepage.localhost";
}
