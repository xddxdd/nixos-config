_: interface: {
  networkConfig.DHCP = "yes";
  matchConfig.Name = interface;
  routes = [
    {
      Destination = "10.0.0.0/8";
      Gateway = "_dhcp4";
    }
    {
      Destination = "172.16.0.0/12";
      Gateway = "_dhcp4";
    }
    {
      Destination = "192.168.0.0/16";
      Gateway = "_dhcp4";
    }
  ];
}
