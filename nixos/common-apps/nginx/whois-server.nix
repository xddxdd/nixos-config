{
  pkgs,
  ...
}:
let
  whoisDelegations =
    pkgs.runCommandLocal "whois-delegations.js"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        python3 ${./whois-server/delegations.py} ${pkgs.whois.src} > "$out"
      '';
  whoisScript = pkgs.writeText "whois.js" (
    builtins.replaceStrings [ "@delegations@" ] [ "${whoisDelegations}" ] (
      builtins.readFile ./whois-server/handler.js
    )
  );
in
{
  lantian.nginxVhosts."whois.lantian.pub" = {
    listenHTTP.enable = true;
    listenPlainSocket = {
      enable = true;
      socket = "/run/nginx/whois.sock";
      proxyProtocol = true;
      default = true;
    };
    enableCommonLocationOptions = false;
    enableCommonVhostOptions = false;
    serverAliases = [
      "whois.lantian.dn42"
      "whois.lantian.neo"
    ];
    root = "/nix/sync-servers/ltnet-registry/dn42/data";
    extraConfig = ''
      js_engine qjs;
      js_import whois from ${whoisScript};
      js_var $whois_backend;
      js_var $whois_query;
      js_var $whois_prefix_sent;
      error_page 400 = /whois-invalid.internal;
      error_page 429 = @whois-limited;
    '';
    locations = {
      "/".extraConfig = ''
        limit_req zone=slow burst=5 nodelay;
        limit_req_status 429;
        js_content whois.lookup;
      '';
      "@whois-remote".extraConfig = ''
        proxy_pass http://$whois_backend:43/$whois_query;
        proxy_http_version plain;
        # The plain-proxy patch still emits Host unless explicitly cleared.
        proxy_set_header Host "";
        proxy_pass_request_headers off;
        proxy_pass_request_body off;
        proxy_connect_timeout 5s;
        proxy_read_timeout 15s;
        proxy_send_timeout 5s;
        proxy_buffering off;
        js_header_filter whois.remoteHeaders;
        js_body_filter whois.prepend buffer_type=buffer;
      '';
      "= /whois-invalid.internal".extraConfig = ''
        internal;
        js_content whois.invalid;
      '';
      "@whois-limited".extraConfig = ''
        js_content whois.limited;
      '';
    };
    sslCertificate = "lets-encrypt-lantian.pub";
  };

  systemd.services.nginx.confinement.packages = [ whoisScript ];
}
