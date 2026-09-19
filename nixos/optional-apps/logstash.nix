{
  pkgs,
  ...
}:
{
  services.logstash = {
    enable = true;
    package = pkgs.logstash7-oss;
    logLevel = "error";
  };

  systemd.services.logstash.serviceConfig.Restart = "always";
}
