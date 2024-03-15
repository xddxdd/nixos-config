{ tags, geo, ... }@args:
{
  index = 7;
  tags = with tags; [
    public-facing
    qemu
    server
  ];
  city = geo.cities."JP Tokyo";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMDWloT27dXqxzdR7simTpNVcdb/ygfkkvUDtSR37aaDFNjRGHEO6HQ/wV831ISwZlSRZUiLkvFD9uelquHvFxwnRzDNz/Rqxc8LJMgdhYUPvJL6kA7kn7RcZe/raEVyWpRhYBHNKTcc/WL5/xuJUmJvGCTuIblXog0dtmeLn4MtrMAC+SpxkuUYLDKqhNKk9I4gdpLkr/OuceAIxiCwvJOq6gOl0wJJtFOOsHU2rTW4XNn8uTjhF/KuYEC17DGx4QQik0Vq7LXNhfjQutdLoS82OX1cCci/0ybB2p0785wK9+6QkJIDqmohb3D4Anw5P8ZCSrxKl+XCAd6hGl+QVAXdy+JYchfsS/ldxS/BS/+JHNjqjeQizuqYUiEP4CVk8yMoh7eMr/ldFCxOb78/hZSYvtPybw+tkkLqXBreMle4v/V8unkrfWFnxelmn3duHsPE/yjDPLGwJSIQzNvxKldKgj86UnxRCuRQCurcxRWNIWa/ttFnLfKY0VrKi/3uKXR0BOhVQUZdeRQ0DhOhsqFUMN+8WLQmaj3WfABV1eTFWEzmul9zQUapCVGePFsDiyCidr2UgeT/RgCmomkxndkLl/2ROwjkw7hUYqy0vRHdq5nd8i4tczdZYzVGrRsVd7qQ4VMEn/x1GnCwsa7qNsi6y2EygKU6LtxySDYhTwAQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzrBeumtGvE+EZ0qlHMs43DMQ+jBXawKa4ztYFS2cTb";
  };
  public = {
    IPv4 = "140.238.54.105";
    IPv6 = "2603:c021:8000:aaaa:3::1";
  };
  dn42 = {
    IPv4 = "172.22.76.124";
    region = 52;
  };
}
