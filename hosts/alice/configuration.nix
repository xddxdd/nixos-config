{
  inputs,
  ...
}:
{
  imports = [
    ../../nixos/server.nix

    ../../nixos/optional-apps/ndppd.nix

    (inputs.secrets + "/dn42/alice.nix")

    ./hardware-configuration.nix
  ];

  systemd.network.networks.eth0 = {
    address = [ "2.26.205.141/23" ];
    gateway = [ "2.26.204.1" ];
    matchConfig.Name = "eth0";
  };

  services.ndppd.proxies.eth0.rules."2a14:67c0:306:211::/64".method = "static";

  # DN42 legacy address
  systemd.network.networks.dummy0.address = [ "fdbc:f9dc:67ad::8b:c606:ba01/128" ];
}
