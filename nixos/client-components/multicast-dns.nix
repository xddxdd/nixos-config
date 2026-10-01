{
  LT,
  lib,
  config,
  ...
}:
{
  lantian.firewall.presets.public-firewall.firewalledPorts = lib.mkIf config.services.avahi.enable [
    LT.port.mDNS
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    reflector = !(LT.this.hasTag LT.tags.client);
    wideArea = false; # CVE-2024-52615

    publish = {
      enable = true;
      addresses = !(LT.this.hasTag LT.tags.client);
      domain = true;
      hinfo = !(LT.this.hasTag LT.tags.client);
      userServices = true;
      workstation = !(LT.this.hasTag LT.tags.client);
    };
  };
}
