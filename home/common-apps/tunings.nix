{ pkgs, ... }:
{
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    lfs.enable = true;
    extraConfig = {
      core = {
        autoCrlf = "input";
      };
      pull = {
        rebase = false;
      };
      push = {
        autoSetupRemote = true;
      };

      # https://forums.whonix.org/t/git-users-enable-fsck-by-default-for-better-security/2066
      transfer.fsckobjects = true;
      fetch.fsckobjects = true;
      receive.fsckobjects = true;
    };
    userName = "Lan Tian";
    userEmail = "xuyh0120@outlook.com";
  };

  # Mute GNU Parallel citation notice
  home.file.".parallel/will-cite".text = "";

  home.packages = [ pkgs.git-filter-repo ];

  xdg.configFile = {
    "nix/nix.conf".text = ''
      experimental-features = nix-command flakes ca-derivations auto-allocate-uids cgroups
      extra-experimental-features = nix-command flakes ca-derivations auto-allocate-uids cgroups
    '';
    "nixpkgs/config.nix".text = ''
      { allowUnfree = true; }
    '';
  };
}
