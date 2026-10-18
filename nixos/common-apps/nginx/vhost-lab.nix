{
  config,
  ...
}:
{
  lantian.localVhosts.lab = {
    root = "/var/www/lab.${config.networking.hostName}.xuyh0120.win";
    locations."/".enableAutoIndex = true;
  };

  systemd.tmpfiles.settings.nginx = {
    "/var/www/lab.${config.networking.hostName}.xuyh0120.win"."d" = {
      mode = "755";
      user = "root";
      group = "root";
    };
  };
}
