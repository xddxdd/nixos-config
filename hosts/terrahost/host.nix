{
  tags,
  geo,
  ...
} @ args: {
  index = 11;
  tags = with tags; [public-facing server];
  city = geo.cities."NO Sandefjord";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDL4OQIUTdyZynG4B+/1GFjMoQKX9xq1BVyOF8spXWNcUDqPUfetgA0H5CLILvUZTyR5thM7zS5gQdn01m1qznMXoGtOQqVBTLGS6ZV8J2rO3/vwKseJYh6rNiaImWu6mEu/G6k3v3xrtan9j+Y9X+vLPGHY90uASzYv45VaU/xW/4ChDLfQZitLW3lyGz3DZqXDTZZDzLeHCMwFFYw7GcIG67E30IoDd8300wqRg3sCeTb8XwqqhA2YDn/UuTJNQTHaRCFEt5x92FILmzbT1WxFYh3UXZ6VTGZQ+OLRbqhTq1IiyaV9B4reiglyAC6P8IMjpl3yqhF+pvJodSzIi6cEutbVZ7nP61nu2InsjvHfHumh5dPSJcpYmiOFcUtyLx/YKPHbw92B1yMWai5t+Y359xgJpJvIX8Tuoeu4S/zheAD1q2/8zf/ueCBZfniTU7xrdL3KJFcyLwqEWvUr+/ZtmjodGUj6jij0cqXCaDuqqy0/+HYmvVfBSZ11aQIM1liEa4w5y2gJyNW7fz613OvHd6JXglz9FSYlSmQudNYYaLGy7ltBQfInJXwzdcO+jmZjif9pjQBPXXVXUx9SErM30Dg8//gK4OR/YxhMyReIStQkVN1OPILyOGWFSo2ryCNpjwNHzHba18jZaS7HPt8ebL4KsULZEEVKozUK8ARcw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3gI3Xp4vuhLA7syB110Dt46tAZQvBm+TEQ7Pg25HY7";
  };
  public = {
    IPv4 = "194.32.107.228";
    IPv6 = "2a03:94e0:ffff:194:32:107::228";
  };
  dn42 = {
    IPv4 = "172.22.76.122";
    region = 41;
  };
}
