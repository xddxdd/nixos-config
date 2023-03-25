{
  tags,
  geo,
  ...
} @ args: {
  index = 101;
  tags = with tags; [client nix-builder];
  # CPU for lt-lenovo is throttled to 50%
  # cpuThreads = 8;
  cpuThreads = 4;
  city = geo.cities."US Chicago";
  hostname = "192.168.0.6";
  manualDeploy = true;
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZcTivKNdS8+var7e60bl8JZPJhhbfHuOhmVwVt3zsoi6vOeMKjOLT+HKgvjGL6ctRB4bafdf24FdGlyWsbA7WC6Dmt7IcKVkPkMXzRfMF9KqngyYHnC5gwyraEkJ9BXZBYnAQeLKs7YQBb7LwQNXwaKsSRewyWSu//6EVqd/1NrzgOP8AXL446jjzoUizFN5f0xM/9b7wllH70VnvKVIGa2djU87QtX0XHda2yyx+GmCy9ic2qtn3Tpu0h6ex89p/ppymq4WxF5GizPF3neqp6K2EEAOfD667c+B/C8EYD8ltt3kBcOxNj7udk5ZwAmpDIf6U8gZxyaxaZ1vUWdrfw/AsQehQDi9wRr/Z77Bc57WnNI3Ib3TpcbAc+UE313Pg557WO8msyIgG2fovCrgj1Ez8eM54y/JDD6ekez8zSBNggm4D8m9MufDd9EohCP02t6rIKLrQmHAYOeKIVqwc49pF0yNk1ddJZSgMJszYY1km82V9zUtX6Kr2CoRyrJ+tWOxb8K95V/RqYC9Ll/r3hqc7uMFvgg8B0N1hIUpQDnqNQIhfz8ysjVeHrS/S3+w/Kg80TPSQhv9nXhXQ255UC2OCX5Eu9f9DYFewxBcDxKTEU52/yxkigmiYRsSOAVMdfkpGgDYPdrO8hIS++qclbeTLiW9a7PIO350fwLYX3w==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+dRFR7ZEU/XyPl4EyAsWD/cSDdWkoa2OL9A2WAMllG";
  };
  dn42 = {
    IPv4 = "172.22.76.115";
    region = 42;
  };
}
