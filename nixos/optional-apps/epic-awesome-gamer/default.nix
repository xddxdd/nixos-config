{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  startScript = pkgs.writeShellScript "epic-awesome-gamer" ''
    ${lib.getExe pkgs.gnupatch} -p1 < ${./fix.patch}
    xvfb-run --auto-servernum --server-num=1 --server-args='-screen 0, 1920x1080x24' uv run app/deploy.py
  '';
in
{
  sops.secrets.epic-awesome-gamer-env.sopsFile = inputs.secrets + "/epic-awesome-gamer.yaml";

  virtualisation.oci-containers.containers.epic-awesome-gamer = {
    image = "ghcr.io/qin2dim/epic-awesome-gamer:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    cmd = [ "${startScript}" ];
    environmentFiles = [ config.sops.secrets.epic-awesome-gamer-env.path ];
    volumes = [
      "/var/lib/epic-awesome-gamer:/app/app/volumes"
      "/nix/store:/nix/store:ro"
    ];
  };

  systemd.tmpfiles.settings = {
    epic-awesome-gamer = {
      "/var/lib/epic-awesome-gamer".d = {
        mode = "755";
        user = "root";
        group = "root";
      };
    };
  };
}
