_: interface: metric: {
  networkConfig.DHCP = "yes";
  matchConfig.Name = interface;
  ipv6AcceptRAConfig.RouteMetric = metric;
  routes =
    map
      (dest: {
        Destination = dest;
        Gateway = "_dhcp4";
        Metric = metric;
      })
      [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
      ];
}
