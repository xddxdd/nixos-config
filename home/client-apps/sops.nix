{
  pkgs,
  lib,
  ...
}:
{
  home.activation.setup-sops-key = ''
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
      mkdir -p $HOME/.config/sops/age
      ${lib.getExe pkgs.ssh-to-age} -private-key -i "$HOME/.ssh/id_ed25519" > "$HOME/.config/sops/age/keys.txt"
    fi
  '';
}
