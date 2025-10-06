{ tags, geo, ... }:
{
  index = 101;
  tags = with tags; [
    server
  ];
  cpuThreads = 64;
  city = geo.cities."US Seattle";
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7Nsm2heQCuKGFldsv2TzaO0fGTAS3Knzy4Coplg4vnJ1CLWYMp1ogizxcRhtvF53DCwYSe8wIlv+b4/Pa+CbTYKo2j9ZUNOFFuZJF8EtpWD69iG2eLwXwNjbnJ4AjZO4JJmRCdF+SNbrNHYC+IZjFRJgtSjHEXnkLzSV4qr+UTM0Ldst7F7Agmq+UW4Z5eXmAzqv/5RLHOG0DOqcq9s+oeIMEBPET8RncTDXg/qTF1ZrT4L2wdmmynMjvrRNSNC22K5wKzEZnqBfjoI3bWuPw3OovLFbxWKDyZSgD2w9PCDriFBm3UOqSEUOATTAvTvaEsOcy6aWiONrsMSgeptCDyl1WcsIFAK/kqoAN84VRzrFnJU1Pb027py62QBdGFvUv6fxC83j0C8K546KLfxNSLQvHRgeLjxez8lPamYWYjU/JmBjWgZH+5CxbfY+wscxa531AaEy0LszPaXiwpuPaLfKPAptzRg/CG4q805jPmWm5wEH64rijwADTQ6heK/dACFj95Hbb7hvz+aFfyH2QV7Kk+RhJ3uhqjEFLUKVhsQZiIRgcDDejM7MWIVErvgr6dmzFdOMMCrgAoMUXo2zAHCdjUEpaKSy7m0aaRpbW2FD6RPrnlJq45x+OZiUNTiyaNlXtF0CFo/C6O2CIjqqBKqpCiWpBjicuSKZsXPT0Kw==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2yEmewk6E2jKDjJOdrC4k4It2SN+/ihSOwsVmd9fnW";
  };
  zerotier = "606bdb9703";
  firewalled = true;
  public = {
    IPv6 = "2001:470:e997:1::10";
  };
  dn42 = {
    IPv4 = "172.22.76.113";
    region = 42;
  };
  additionalRoutes = [ "10.20.20.77/32" ];
}
