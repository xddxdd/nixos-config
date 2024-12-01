{ tags, geo, ... }:
{
  index = 3;
  tags = with tags; [
    dn42
    public-facing
    qemu
    server
    x86_64-v1
  ];
  city = geo.cities."US Los Angeles";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4aYURWnQGEkxYueAnGgZQbrQA+SHNLRgpJZd+2J9DyKdtoqXRhSjGEAGJkqBg8alWadaYJ15wvKj5BHoTQCao6XXzuxsP35Y+xtaWJ0wJ5ZJ3/J8l4z0V/85EdYqxPInQe0cpfqTEt+lnqlOOeq4f9522OMErSzefAk/MHp+OxDWr2ZdrZVggGVFpujFdCU3ckM8NMCZUufOXX2+wXQfkMXd3umGaM3oMJl6bIEyqtLwlCWnSuMEXS5JwnZ3lhKg73PO5tRaq2FcL8RXaph9uiHWmP/ch2RTnJ4xjmbhiGQuaebtCUnfW6sDZPfOv5KOx5T4V8yBOtnyDPoS2mYKva1I9HztW4JgzWzTRonFqbaH61jFalyWPTPMt/W1gQWZEnWbCewt+jBGUApBTaxDnKXywGxyjpb7MOfdLAuDkr19p9PR04G5BOw940CXeU3K0KvLjwsQN3ptHL4t6GesNWcZ3x8cxZbvi3n58GUgGjjxTro+TXgzqPU9U7JYeFPwdgoytBSPucA4DheYCkV6/V30tX8UETpGuSzWUplyVCbbXbZYGh6ulce3X4xXn0Nir3F4bzTCQlvzTWz8zkmHW1QERmStVhMJD2K7JWpe0h97zzi+jFv9QLLnfBBKjia02s7if3sZTjk4jI59B3X9Fmf3faeNXIoDMRBJcIwFtyw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7jqK5IsCqMJqJUhAk2oQBQHhvxEb2q39BKNi1VsyOg";
  };
  public = {
    IPv4 = "64.64.231.82";
    IPv6 = "2001:470:1f05:159::1";
  };
  dn42 = {
    IPv4 = "172.22.76.185";
    region = 44;
  };
}
