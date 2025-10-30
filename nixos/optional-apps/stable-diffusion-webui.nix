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
      "--net=host"
      "--gpus=all"
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
    image = "docker.io/universonic/stable-diffusion-webui";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    volumes = builtins.map (f: "/var/lib/stable-diffusion/${f}:/app/stable-diffusion-webui/${f}") (
      subfolders ++ files
    );
  };

  # Container uses UID/GID 1000
  systemd.tmpfiles.settings = {
    stable-diffusion = builtins.listToAttrs (
      (builtins.map (f: {
        name = "/var/lib/stable-diffusion/${f}";
        value = {
          "d" = {
            mode = "755";
            user = "1000";
            group = "1000";
          };
        };
      }) subfolders)
      ++ (builtins.map (f: {
        name = "/var/lib/stable-diffusion/${f}";
        value = {
          "f" = {
            mode = "755";
            user = "1000";
            group = "1000";
          };
        };
      }) files)
    );
  };

  lantian.nginxVhosts = {
    "stable-diffusion.xuyh0120.win" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${LT.portStr.StableDiffusionWebUI}";
        proxyWebsockets = true;
      };

      sslCertificate = "zerossl-xuyh0120.win";
      noIndex.enable = true;
      accessibleBy = "private";
    };
  };
}
