_: {
  services.angrr = {
    enable = true;
    settings = {
      temporary-root-policies = {
        direnv = {
          path-regex = "/\\.direnv/";
          period = "14d";
        };
        result = {
          path-regex = "/result[^/]*$";
          period = "3d";
        };
      };
      profile-policies = {
        system = {
          profile-paths = [ "/nix/var/nix/profiles/system" ];
          keep-since = "14d";
          keep-latest-n = 5;
          keep-booted-system = true;
          keep-current-system = true;
        };
        user = {
          enable = false; # Policies can be individually disabled
          profile-paths = [
            "~/.local/state/nix/profiles/profile"
            "/nix/var/nix/profiles/per-user/root/profile"
          ];
          keep-since = "1d";
          keep-latest-n = 1;
        };
      };
    };
  };
}
