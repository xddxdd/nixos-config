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

  # Split a hostname into the scheme/proto prefix, the subdomain label to
  # highlight, and the trailing domain suffix to dim. The longest matching
  # suffix wins so that a per-host suffix like ".<host>.xuyh0120.win" dims more
  # than the bare ".xuyh0120.win". Nix's regex engine is POSIX (no lazy
  # quantifiers), so `^(.*)(suffix)$` would give the prefix the longest match and
  # the suffix the shortest. Instead we anchor only the suffix at `$` and let
  # builtins.split find the leftmost match: the earliest position from which a
  # suffix reaches the end is the longest suffix, and POSIX leftmost-longest then
  # resolves ties between alternatives.
  splitName =
    e:
    let
      inherit (e) scheme name src;
      proto = "${scheme}://";
      pattern = "(\\.${src}\\.lantian\\.pub|\\.${src}\\.xuyh0120\\.win|\\.lantian\\.pub|\\.xuyh0120\\.win|\\.localhost|lantian\\.pub|xuyh0120\\.win)$";
      parts = builtins.split pattern name;
    in
    if builtins.length parts == 1 then
      {
        url = "${proto}${name}";
        inherit proto;
        highlight = name;
        suffix = "";
      }
    else
      {
        url = "${proto}${name}";
        inherit proto;
        highlight = builtins.elemAt parts 0;
        suffix = builtins.elemAt (builtins.elemAt parts 1) 0;
      };

  linkRecords = lib.pipe allEntries [
    # Not an internal catch-all (serverName starting with "_")
    (builtins.filter (e: !lib.hasPrefix "_" e.name))
    # Not a wildcard vhost (name containing "*")
    (builtins.filter (e: !lib.hasInfix "*" e.name))
    (builtins.filter (e: !lib.hasPrefix "www." e.name))
    # Ends with .lantian.pub, .xuyh0120.win, or .localhost
    (builtins.filter (
      e:
      lib.hasSuffix ".lantian.pub" e.name
      || lib.hasSuffix ".xuyh0120.win" e.name
      || lib.hasSuffix ".localhost" e.name
    ))
    # .localhost entries are only kept from the current host (they are per-host)
    (builtins.filter (e: !lib.hasSuffix ".localhost" e.name || e.src == thisHost))
    # Not the redundant per-host top-level alias <host>.lantian.pub or
    # <host>.xuyh0120.win (subdomains like <svc>.<host>.<domain> are kept)
    (builtins.filter (e: !(e.name == "${e.src}.lantian.pub" || e.name == "${e.src}.xuyh0120.win")))
    (builtins.map splitName)
    (builtins.foldl' (acc: r: if builtins.any (x: x.url == r.url) acc then acc else acc ++ [ r ]) [ ])
    (builtins.sort (a: b: a.url < b.url))
  ];

  linksHtml = lib.concatMapStringsSep "\n" (r: ''
    <li><a href="${r.url}" target="_blank">${r.proto}<span class="hl">${r.highlight}</span>${r.suffix}</a></li>
  '') linkRecords;

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
