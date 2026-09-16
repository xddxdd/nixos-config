{
  config,
  ...
}:
{
  services.kubo.enable = true;

  systemd.services.ipfs = config.lantian.netns.tnl-buyvm.bind {
    serviceConfig.Restart = "on-failure";
  };

  users.users.lantian.extraGroups = [ config.services.kubo.group ];
}
