{
  inputs,
  config,
  lib,
  LT,
  ...
}:
lib.mkIf (LT.this.hasTag LT.tags.nix-builder) {
  sops.secrets.nix-github-key.sopsFile = inputs.secrets + "/nix-builder.yaml";
  sops.templates.nix-include = {
    content = ''
      access-tokens = github.com=${config.sops.placeholder.nix-github-key}
    '';
    mode = "0444";
  };

  nix.extraOptions = ''
    !include ${config.sops.templates.nix-include.path}
  '';
}
