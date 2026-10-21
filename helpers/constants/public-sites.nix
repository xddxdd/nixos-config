{ lib, replacedHosts, ... }:
[
  # Public static pages
  # keep-sorted start
  "_default_http"
  "_default_https"
  "api.lantian.pub"
  "autoconfig.lantian.pub"
  "autoconfig.ltn.pw"
  "autoconfig.xuyh0120.win"
  "avatar.lantian.pub"
  "element.lantian.pub"
  "gemini.lantian.pub"
  "gopher.lantian.pub"
  "lab.lantian.pub"
  "lab.xuyh0120.win"
  "lantian.dn42"
  "lantian.neo"
  "lantian.pub"
  "ltn.pw"
  "posts.lantian.pub"
  "sip.lantian.pub"
  "stage1.whois.local"
  "stage2.whois.local"
  "tools.lantian.pub"
  "whois.lantian.pub"
  "www.lantian.pub"
  "www.ltn.pw"
  "xn--gmqs02au1c935d.pub"
  "xuyh0120.win"
  # keep-sorted end

  # Has own authentication system
  # keep-sorted start
  "at.lantian.pub"
  "attic.xuyh0120.win" # currently showing compromised warning
  "comments.lantian.pub"
  "git.lantian.pub"
  "hydra.lantian.pub"
  "matrix-client.lantian.pub"
  "matrix-federation.lantian.pub"
  # keep-sorted end

  # Intentionally public without authentication
  # keep-sorted start
  "flapalerted.lantian.pub"
  "lg.lantian.dn42"
  "lg.lantian.pub"
  "ollama-cpa-honeypot-cpa"
  "ollama-cpa-honeypot-ollama"
  # keep-sorted end
]
# 301 redirect vhosts for replaced old host names: serve no content, just redirect
++ (lib.mapAttrsToList (n: _: "*.${n}.xuyh0120.win") replacedHosts)
