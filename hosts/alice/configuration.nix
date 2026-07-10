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
    address = [ "2.26.205.141/23" ];
    gateway = [ "2.26.204.1" ];
    matchConfig.Name = "eth0";
  };

  networking.henet = {
    enable = true;
    remote = "216.218.221.6";
    addresses = [
      "2001:470:18:3de::2/64"
      "2001:470:19:3db::1/64"
      "2001:470:fa05::1/48"
    ];
    gateway = "2001:470:18:3de::1";
  };

  # DN42 legacy address
  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::8b:c606:ba01/128" ];
}
