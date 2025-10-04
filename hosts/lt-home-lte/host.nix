{ tags, geo, ... }:
{
  index = 110;
  tags = with tags; [ ];
  hostname = "192.168.0.9";
  cpuThreads = 4;
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPBIqdZ+Z1HO1oF8qwwykpndVeicLPqaC5QXZ6qODymxo9j+56k16ynLzmWTMl7qh+QGHeJ+R1/5Uqbbg9qPoVnA879lZnrjP2gT2Pd0lm/dl6rpyUyZmckPfaFkTkddwdhYWTs1vVQeD4OpRl6JWDDuZolX6bWeW1gEibOxv1N1K9hSh163UNNWQ3pUPfWcj8s3JSxSb0bdTObGjuhKh0k5mZnzKnAp7dClJPaQL8l6q90GVrh3DYinBrqaw3JA96q0obRfeVJT/nItl5jCLKSBib3ovDiygOjVL4+67PROSXTL7NnXtI8GYRz/IfXW20DdrxISCl0+iBE8Nayg3vT+aP3I1E2k3Uf3OauYoJzuqC/zm+nn2fm8MjVoLYZ4doYCfoVaXqgPVgjia8gMZqkuU3qGWmYX6LLdYAmlHsI5qs775sxd1gx8ztndHmO/4viCWvTpgohbc2CirdiCFn4hX8x8p7u52koqNNDpG4D6Q9e4SuD17Ptuvs4qpDW2ssM2oFRZfmJ2wLHscIxrmSz30jkfrL0ZXUvTSFXZ10HUZU3Q+u4LzCIy9oXyrkOaiVJnvq5tIXyS10+h+AWon3WIyHFTMZMj8aZZ3eTGzmHOj+XvpeevuFgAqcmtd6BOcgBY3x2Qzd+grDnWpFB2HfshEwDgpV8Eg5SxDpGu0JDQ==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBxrIX4CD7YIEOBeo02Jcck3BYesAOoCZ8fjCBG6fxk";
  };
  zerotier = "7694587830";
}
