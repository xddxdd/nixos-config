{
  inputs,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    (inputs.secrets + "/dn42/alice.nix")

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [
      "2.26.205.141/23"
      "2a14:67c4:12::c3/64"
    ];
    gateway = [
      "2.26.204.1"
      "2a14:67c4:12::1"
    ];
    matchConfig.Name = "eth0";
  };

  # DN42 legacy address
  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::8b:c606:ba01/128" ];
}
