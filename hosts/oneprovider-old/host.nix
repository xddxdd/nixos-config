{
  tags,
  geo,
  ...
} @ args: {
  index = 10;
  tags = with tags; [nix-builder server];
  cpuThreads = 8;
  city = geo.cities."FR Paris";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5a2K6h3RbZpNnRMCHdd2wH1H3MJtiSUe0UhhE/6MnE6GJEgP1Kbt0JBVwMn/UEaKfcdHdUhSQGg95q8Z87gbuyvmXiAj1xFyqdOTrZwqyLDPj9gCe/krA/02z6O9hxaqF2FMJwudcqq0Um/ppxbHGkFH+KURzbdIH/CSBuyrqGl6v/lWbmyI4H4NpZZCo37y8NVicfTsljDxcQpQzy7iEXvwAdjqQI8HSxM+8Kx5BIuV5rAmJzF1Pb+GaZXodvVRIULa3zvfUfaEhYbKTukgvwdwMSB5eigO6WRjqJWgz9/6VCy/JRZ3UQVNRh98FZVBktj3qN4WsR/NpcmS7eFv7p1WWnWj/YjxtPTlB7jUnA8wthqCqyCOQi8ABbt/hmSqmTVbpDm/IWefsgdJIjarkreEToeEne3BSwJ/crhLejitpMjM5RvcOurpUY14kZTBwbcE8gB0TS7j73+GvXLHs7FSkeVpdDC6gW4RZkYmMcT0+H/mybASET0bgMwCakIZ8QSVGJ49JWmvXRYRNlBjoHu44HITa5R8ya2OjxLunPXbk7d9EUyyejLwq33+zRucJD7NiokKyLxfgS9zqlr1kV44ehP04mg+mHKKDxdKoY1bYlYbBXDNi/RSP65MlGBcznAECOyQAoxWLtdK0mW+tJpGkCGt2iplDoF5dJHhG5w==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICFZz8i4n3uwXrVFyKn/QxHst3FpbYKB8uoR2YZzI4U6";
  };
  public = {
    IPv4 = "51.159.15.98";
    IPv6 = "2001:470:1f13:3b1::1";
    IPv6Alt = "2001:470:cab6::1";
    IPv6Subnet = "2001:470:cab6:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.113";
    region = 41;
  };
}
