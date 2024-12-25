_: {
  systemd.network.networks.dummy0.address = [ "10.20.20.77/32" ];

  virtualisation.oci-containers.containers.bxcq3 = {
    extraOptions = [
      "--pull=always"
      "--interactive"
    ];
    image = "amilys/bxcq";
    ports = [
      "10.20.20.77:81:81"
      "10.20.20.77:9001:9001"
      "10.20.20.77:9002:9002"
    ];
    volumes = [
      "/var/lib/bxcq3/www:/www"
      "/var/lib/bxcq3/data:/data"
    ];
  };
}
