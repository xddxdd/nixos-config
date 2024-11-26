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

  files = [
    "config.json"
    "ui-config.json"
  ];
in
{
  virtualisation.oci-containers.containers.stable-diffusion = {
    extraOptions = [
      "--pull"
      "always"
      "--net"
      "host"
      "--gpus"
      "all"
    ];
    entrypoint = "/app/entrypoint.sh";
    cmd = [
      "--api"
      "--disable-console-progressbars"
      "--no-half-vae"
      "--port=${LT.portStr.StableDiffusionWebUI}"
      "--update-check"
      "--xformers"
    ];
    image = "universonic/stable-diffusion-webui";
    volumes = builtins.map (f: "/var/lib/stable-diffusion/${f}:/app/stable-diffusion-webui/${f}") (
      subfolders ++ files
    );
  };

  # Container uses UID/GID 1000
  systemd.tmpfiles.rules =
    (builtins.map (f: "d /var/lib/stable-diffusion/${f} 755 1000 1000") subfolders)
    ++ (builtins.map (f: "f /var/lib/stable-diffusion/${f} 755 1000 1000 - {}") files);

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
