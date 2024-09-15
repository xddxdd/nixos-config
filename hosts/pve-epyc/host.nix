{ tags, geo, ... }:
{
  index = 108;
  tags = with tags; [
    exclude-bgp-mesh
    nixpkgs-stable
    server
  ];
  city = geo.cities."US Seattle";
  hostname = "192.168.0.2";
  manualDeploy = true;
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnHv6Lm8vGEtT32pgECJVlbb+n0lj1RK+v6CwVk6YXvGxYqhX/mcwg6aCExJnLjUEvqUGtht1tDY+bXIqKIYAtSJU11P2V8el4PkZ0tRiXA7xCXP1wh5d3sKDpRouQHXHuDXohSD1IMi1YWbPVHyQVBeIEff0Y43qYbtK+B1yaoU1P6mdeWsfLdSutWPP90vneMkkdjTMG6wT8Pe8ZosVSCTA89UN60HlWAn6SjLaTTTQxwsoBOGMhQ/HahAWDTSjjfFcf0tfboOKRQayt+ySyivHmkjqS7Sj+ZDX0PcCsdvAxdIAQvKZFTxKjUPuRmXQxSziXZ+gN7TlogvAYz7M1plnpVmYxYVKUknBQcO8nZqu2je5F0W94iVmo/bdRvOH5uN8Wu5DAVKuXYEJ2WJr0LC1BTnWG+DKYDSwoYNMYPfGt2m9jUfZ6jfgQL+awMnQH1SovsTZWxOWKmK7W3Z973/OAYQdJUIzYUYGRKASTJo8vt3uNU5f1zfjsB1/6iE+PGgXJuvvTlhpoNgp08OGh0AWHOMV7lCX5kwM1sR8vLkzXu9DJRXm/6FMVJjQ1D5OPJoZmvnXhEFv/4V93ZOOD+W32JGcwY1bn3mlNNHiODS/RyomvItCuW8K6JMvgRk8w4Wmtb4+tGdL8XUFkJGmnD+Bj6QJEGGe0o2bB1lZ3GQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3PpFGm+OTqrJM55qrxKWLnkwrnnzzMAprNfaXWk/gp";
  };
}
