{ LT, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    reflector = !(LT.this.hasTag LT.tags.client);
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
