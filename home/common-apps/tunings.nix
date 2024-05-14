{ pkgs, ... }:
{
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;
    extraConfig = {
      core = {
        autoCrlf = "input";
      };
      pull = {
        rebase = false;
      };
    };
    userName = "Lan Tian";
    userEmail = "xuyh0120@outlook.com";
  };

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
