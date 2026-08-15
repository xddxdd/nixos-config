{
  lib,
  osConfig,
  ...
}:
let
  # Only active on hosts that import the NixOS homepage module, which adds the
  # homepage.localhost vhost.
  enabled = (lib.attrByPath [ "lantian" "nginxVhosts" ] { } osConfig) ? "homepage.localhost";
in
lib.mkIf enabled {
  programs.firefox.profiles.lantian.settings = {
    "browser.startup.homepage" = "http://homepage.localhost";
    # anti-fingerprinting.nix forces browser.startup.page to 0 (blank); override
    # it so Firefox launches onto the home page.
    "browser.startup.page" = lib.mkForce 1;
  };
}
