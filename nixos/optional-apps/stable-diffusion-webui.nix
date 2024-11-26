{
  LT,
  ...
}:
let
  subfolders = [
    # Data folders
    "inputs"
    "textual_inversion_templates"
    "embeddings"
    "extensions"
    "models"
    "localizations"
    "outputs"
    # Cache across container runs
    "venv"
    "repositories"
  ];
in
{
  virtualisation.oci-containers.containers.stable-diffusion = {
    extraOptions = [
      "--pull"
      "always"
      "--gpus"
      "all"
    ];
    image = "universonic/stable-diffusion-webui";
    ports = [ "127.0.0.1:${LT.portStr.StableDiffusionWebUI}:8080" ];
    volumes = builtins.map (
      f: "/var/lib/stable-diffusion/${f}:/app/stable-diffusion-webui/${f}"
    ) subfolders;
  };

  # Container uses UID/GID 1000
  systemd.tmpfiles.rules = builtins.map (
    f: "d /var/lib/stable-diffusion/${f} 755 1000 1000"
  ) subfolders;

  lantian.nginxVhosts = {
    "stable-diffusion.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.StableDiffusionWebUI}";
        proxyWebsockets = true;
      };

      sslCertificate = "xuyh0120.win_ecc";
      noIndex.enable = true;
    };
  };
}
