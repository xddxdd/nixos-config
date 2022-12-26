{
  config,
  inputs,
  pkgs,
  ...
}:
let
  startScript = pkgs.writeShellScript "epic-awesome-gamer" ''
    ${pkgs.gnupatch}/bin/patch -p1 < ${./fix.patch}
    xvfb-run --auto-servernum --server-num=1 --server-args='-screen 0, 1920x1080x24' uv run app/deploy.py
  '';
in
{
  age.secrets.epic-awesome-gamer-env.file = inputs.secrets + "/epic-awesome-gamer-env.age";

  virtualisation.oci-containers.containers.epic-awesome-gamer = {
    image = "ghcr.io/qin2dim/epic-awesome-gamer:latest";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    cmd = [ "${startScript}" ];
    environmentFiles = [ config.age.secrets.epic-awesome-gamer-env.path ];
    volumes = [
      "/var/lib/epic-awesome-gamer:/app/app/volumes"
      "/nix/store:/nix/store:ro"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/epic-awesome-gamer 755 root root"
  ];
}
