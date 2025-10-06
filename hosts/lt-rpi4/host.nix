{ tags, geo, ... }:
{
  index = 106;
  system = "aarch64-linux";
  tags = with tags; [ ];
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAkdYmCgRVvYOmsN5B/28q5RF7aXPnbmXSjM/4RKZpMdHi4D3RAvmbeRF9w+UlXGSAXnn1Dhj+1lvrkF7Rm7rAZgwal2ctvdDdsEjbUOmdosCN7Os2mzeHRu9bcPqufF8dkp+sWiRGcyH0R/+KTddWm2RydHu4zAVvd7nIW99LHeSRWIuRO/6OVjBUwOZ3h0AtoCTk7a9u/44AC5qCm6JbgUROirbkvbSzl1qtHgLAz5+0szwMwXEfd66caleuSyMvuQQtCrGNHXicrbQE6NAeChyd4Ear0IqoxFmjBG69ab55h+s+sSqvlpnovuCrgezDxTkOJEWcedFDO6bWSxiapqh664oI7zbajkVRU2rJ+YzWh8Gj0IBb+3Jq7zKdDz6TbbC/AkbpNEzkErrPg1nxTim9qWFzQ8fS3TgWfOXg3IoiPz9W8wXbWqJF/R215yHrXG8MDv2SesEs0BjFMPZUjzPpqtsJGAWtFsfHiubFH+a/R2hrl1Ic20JRqouff59Gp0fcQb780HKTxjKj37JXoPBFbJQDkh0rhG+o+2W2GM6TXUCsMHWrTBW/COIK5GUo0JMxj4k3DorKkYuU8vowetkYSNl7GjE4DAEdAiCHG28ccZ3t/7KoAv28k4AE/rUSDv64OPmmRQ1xtaAD3VvvUZEsajBV2AEqY6n1ooTgfw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7wA62a0cowKd4FttudzWfs0GL1wLxCfEOG9QM+odgV";
  };
  zerotier = "a53c247aa1";
  firewalled = true;
  dn42 = {
    IPv4 = "172.22.76.125";
    region = 42;
  };
}
