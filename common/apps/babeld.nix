{
  services.babeld = {
    enable = true;
    interfaceDefaults = {
      type = "tunnel";
      link-quality = true;
      split-horizon = false;
      rxcost = 32;
      hello-interval = 5;
      enable-timestamps = true;
      max-rtt-penalty = 1000;
      rtt-min = 1;
      rtt-max = 1000;
    };
    interfaces.ltmesh = { };
    extraConfig = ''
      kernel-priority 10000
      random-id true
      smoothing-half-life 16

      redistribute proto 12 deny
      redistribute ip 172.18.0.0/16 allow
      redistribute ip fdbc:f9dc:67ad::/48 allow
      redistribute local ip 172.18.0.0/16 allow
      redistribute local ip fdbc:f9dc:67ad::/48 allow
      redistribute local deny
    '';
  };
}
