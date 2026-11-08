{
  LT,
  ...
}:
{
  # mDNS is LAN-only by policy
  lantian.firewall.zones = {
    LAN.udpPorts."${LT.portStr.mDNS}".type = "local";
  };

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
