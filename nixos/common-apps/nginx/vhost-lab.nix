{
  config,
  ...
}:
{
  lantian.localVhosts.lab = {
    root = "/var/www/lab.${config.networking.hostName}.xuyh0120.win";
    locations."/".enableAutoIndex = true;
  };
}
