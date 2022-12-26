{ pkgs, lib, LT, config, utils, inputs, ... }@args:

{
  age.secrets.epic-awesome-gamer-env.file = inputs.secrets + "/epic-awesome-gamer-env.age";

  virtualisation.oci-containers.containers = {
    epic-awesome-gamer = {
      extraOptions = [ "--init" "--pull" "always" ];
      image = "ech0sec/awesome-epic:daddy";
      cmd = [ "xvfb-run" "python3" "-u" "main.py" "claim" ];
      environmentFiles = [ config.age.secrets.epic-awesome-gamer-env.path ];
      volumes = [
        "/var/lib/epic-awesome-gamer/database:/home/epic/database"
        "/var/lib/epic-awesome-gamer/datas:/home/epic/datas"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/epic-awesome-gamer/database 755 root root"
    "d /var/lib/epic-awesome-gamer/datas 755 root root"
  ];
}
