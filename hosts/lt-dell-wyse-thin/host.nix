{ tags, geo, ... }:
{
  index = 105;
  tags = with tags; [ x86_64-v1 ];
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  hostname = "192.168.0.208";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgLylJK13Bk3VmyRzVE+Y+bg2l4WCG9w73NwVT5kt/TnYABq7FBq9q+esn8Otxu5pli1g3gBOmZvGfFm/lH7ouQusYl6ic2d1qkrAam/TSFgcNfS3qsrcCOq2ET5igFd/FUgGRZlV38q8olpuTZI+yyv3lTSeBo2XDaJnPiaieZKQyI666s0cl3jwLb5Qtvcg0KolSTo76jTZZOI/+yWHR6AH5hSCDM8VK0aCe1c25IgIhoaEjIJDm5KzhojarE9qeTy3TjAAbu71h8SE66jqyvOlF1vZ7T0AcP2knVuzu+r1hXnpCJcrCSkgq4EFbbUrjE5lcOFb/lyTHIAXUww9d3ONbb4fmIzaw7FqqjepSTb1OqWI4jnCpzdjwAH849Fnkwvz1BeocA/az5d9efZi+78v99AA4UroQ++Om+xudR+e4mcLkcZ0PwM0tLuENMpbheFVKAJ+241ihD5up4NTXQo/tx/53tJDKwKWsAjIL9C8zO3wn454hxGaPnZSbDP6S7jXHryHy3GcU06vQhSbzDVGRVBvaueA0hp1kJZzgX0H1TFbV5y7zL7rm3oCvxiX7sQjzkCuG6SesJohc/drftmNdT9zATwvVcMqztKKHFme/CY/vGNccnd2i0TX39RCnnG+2gr/RDWhryOUmv1Vuz/I7vMsLdD2sLxkNoUszkQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLKJi1a8Nd0Ay4VgIstCJn6CdLiMvQygL6KriSZ0Aii";
  };
  dn42 = {
    IPv4 = "172.22.76.121";
    region = 42;
  };
}
