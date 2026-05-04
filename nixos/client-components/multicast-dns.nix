{ LT, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    reflector = !(LT.this.hasTag LT.tags.client);
    wideArea = true;

    publish = {
      enable = true;
      addresses = !(LT.this.hasTag LT.tags.client);
      domain = true;
      hinfo = !(LT.this.hasTag LT.tags.client);
      userServices = true;
      workstation = true;
    };
  };
}
