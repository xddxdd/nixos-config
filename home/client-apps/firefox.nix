{
  pkgs,
  ...
}:
let
  args = {
    enable = true;
    package = null; # Already installed system wide
    profiles.lantian = {
      extensions = {
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bilisponsorblock
          bitwarden
          # bypass-paywalls-clean
          clearurls
          darkreader
          dearrow
          downthemall
          enhancer-for-youtube
          fastforwardteam
          flagfox
          i-dont-care-about-cookies
          ipfs-companion
          immersive-translate
          lovely-forks
          multi-account-containers
          noscript
          pakkujs
          pay-by-privacy
          plasma-integration
          protondb-for-steam
          return-youtube-dislikes
          rsshub-radar
          sponsorblock
          steam-database
          tab-reloader
          tampermonkey
          to-google-translate
          ublacklist
          ublock-origin
          wappalyzer
          wayback-machine
        ];
        force = true;
      };

      search = {
        default = "google";
        force = true;
      };

      userChrome = ''
        .titlebar-spacer {
          display: none !important;
        }
      '';
    };
  };
in
{
  programs.firefox = args;
  programs.librewolf = args;
}
