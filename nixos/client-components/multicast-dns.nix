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
    wideArea = false; # CVE-2024-52615

    settings = {
      reflector.enable-reflector = !(LT.this.hasTag LT.tags.client);
      publish = {
        disable-publishing = false;
        disable-user-service-publishing = false;
        publish-addresses = !(LT.this.hasTag LT.tags.client);
        publish-domain = true;
        publish-hinfo = !(LT.this.hasTag LT.tags.client);
        publish-workstation = !(LT.this.hasTag LT.tags.client);
      };
    };
  };
}
