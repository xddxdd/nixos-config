{
  tags,
  geo,
  ...
} @ args: {
  index = 4;
  tags = with tags; [public-facing server];
  city = geo.cities."US New York City";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnpgMzepBss2c522NQot++GUiQ/TLBRwfXD8zfD2XTgnsZwAgRp6A7kCbVAu/CJ5O7UqaFYK6UhiQvPwHdkpLluy7a5ifZrI74dvkRgMg84P5YZXPxNiWWOQH8peiJFZJxG0wKC2ZVP1PmNp/OJJD22dtEXrDlu7lVzIHoIoSoT8qiqIx4VP3jJSM+t4ruuTi44Vvw0S4TjvPfENUcOKrU3nvbpliVkNpuPQROKi26Oz7o2jAVE8QME6Yvh8NVxUQTgqR5lHxBhuP2PTfnKtv6WIJf1xL5EF4WywL1uObc4w3qIAHrRj6ioZD/nFqgaQJpKO3+lmkRhz5iwXPfU19xPq5j0sDRPvoeE8F/P5QgMXJFnDR40YxBtvxUqAbNE9WR4pd0AdX0QwTrWQecAkDXpaY/L524JO5eJacbi/VCLvc3+QLNJDgOeXmIHv2oSF6Rpm2Q+/Tze9YdyjDvdhOmC59kRXx70Vs4SAArU7iF0mVbM8vTCV13DfQCUrf5XoJCX5lekhdIFnj/dju3lJr29POfThquzT6PndL9aRD0mA1ZNR1dk9wwvvv12bVoTgoEiVdSVLY934aMxO7wXSDhsivXXUrexk/lrC6nIF5y4PiORQK/5qtxFwn1tdFMNYb3j8PZcWkfOXErf+ZTarDYTXr6tciEB49WMadeJniOBQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMjmwZpgsCSqgs4kTRqLbkS1uRnNTLGweRqK+YrXs7Qf";
  };
  public = {
    IPv4 = "47.87.186.20";
    IPv6 = "2001:470:1f07:c6f::1";
    IPv6Alt = "2001:470:8d00::1";
    IPv6Subnet = "2001:470:8d00:ffff::";
  };
  dn42 = {
    IPv4 = "172.22.76.126";
    region = 42;
  };
}
