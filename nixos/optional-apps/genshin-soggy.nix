{
  pkgs,
  LT,
  config,
  ...
}:
let
  netns = config.lantian.netns.genshin-soggy;
in
{
  lantian.netns.genshin-soggy = {
    ipSuffix = "26";
    announcedIPv4 = [ "198.19.0.26" ];
    birdBindTo = [ "genshin-soggy.service" ];
  };

  systemd.services.genshin-soggy = netns.bind {
    description = "Genshin Soggy Server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = LT.serviceHarden // {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      Restart = "always";
      RestartSec = "3";
      User = "genshin-soggy";
      Group = "genshin-soggy";
      RuntimeDirectory = "genshin-soggy";
      WorkingDirectory = "/run/genshin-soggy";
    };

    script = ''
      ln -sf ${pkgs.soggy}/opt/soggy.cfg soggy.cfg
      ln -sf ${pkgs.soggy}/opt/static static
      ln -sf ${LT.sources.soggy-resources.src} resources
      exec ${pkgs.soggy}/bin/soggy
    '';
  };

  users.users.genshin-soggy = {
    group = "genshin-soggy";
    isSystemUser = true;
  };
  users.groups.genshin-soggy = { };
}
