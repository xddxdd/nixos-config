{ tags, geo, ... }:
{
  index = 6;
  tags = with tags; [
    server
  ];
  city = geo.cities."CN Hong Kong";
  hostname = "20.255.249.106";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqZrqspTSB5vmIthx5sFbBHb6enkA2LV/g8BTzRpL0g/ACOQpB9KgTKR/wcbckg+ghhFesgpUf0z6eUmOgh9zx96O+Xi0gc7OiWYxgm7riI12liGRC+3k0O1zhl+9QKzApVW/lGNrc7AfKGB2bZn7sZG0sAwT9v2e+0E3Ze7YOQF103v4bEvpmfKW79fK9+Qezt0QWeU+HPHV3CGyAVhS4zxfeWACLk1mvkSgwO7Zbza9p9ZyARwlGd4dP5bkxsViSj2WWNWixCv9Y7nHhNoFo9+xR2bN7ScdDAZz81E6ZLHbVkPC7omUsX6Q+w6qzwUHyxKeKi87LCjB+M27g2+KnlFRe1qJM6X2SggxeL8RE7tgXJCUD8bVBJAaPKu3Yv5VitLDZl/Kls5OU77xnoU1HavyMlyocq9JiYbjDWL3v3DqgkDXFPS05H9FK53lhuwZDcnkhk6L9XkZEB6uYb4EZQpWjeKPjLYUcSZO3VcT66sQYaF1HGgadx5CxHuX9x8POk5ZIDoAyOPmh12dWQSL67lDUelu0i9JgnV8v7McllG4TxaSa+uMsrdwfxfML+F9gmYmfNHNztII0R2kNYm4Wul8vLrg3aIzgS13MZp2yOc0kEX1LaqhKZ5MnER+tQmivyyWzmilK3+kUCiFvwlzKInl4NPI34wLzLf2h+hSkkQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqbBvVUqmS5ffYSF/8nLG3M/RCYGm4Ai3JLhxLmQvut";
  };
  public = {
    IPv4 = "20.255.249.106";
  };
  dn42 = {
    IPv4 = "172.22.76.116";
    region = 52;
  };
}
