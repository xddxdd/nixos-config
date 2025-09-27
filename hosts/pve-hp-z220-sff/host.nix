{ tags, geo, ... }:
{
  index = 109;
  tags = with tags; [
    exclude-bgp-mesh
  ];
  city = geo.cities."US Seattle";
  cpuThreads = 4;
  hostname = "192.168.0.3";
  manualDeploy = true;
  ssh = {
    rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCeo+PHTQKwX1Wqlbo0j0S/hPP1bpan0jZKm7HG3oEWd4H/6epgb1+m7q35ddFflM5xfp7Xjax0iqiXWWcvnuSzssgFibZ2YM/OLLFbILrRQiCedgqCgYSO7QHIlrLFQsSxVeCUUnidvUj4wE68Dd+yt9UxWAcc1pd/g52NpXbCQI5gsWJB2fNdv3nEC9ImoKbAiuxFjIAa81s2R2Idkh0pF+d/dDhGNt7mwoiiEm06HyoJHKOaHfKEOcikOZgGUI+q1gpOmCZontopaAVWTjA0HSmP19PqjQVI7LTdhMUCgJ4urTOdIVmHex9iIzQGNlbLrd9Mkb3MH6FdAXkancfygrkjNI1xZjOEYk1tYKWXEJxS4gkNr35KVln7/RC59dibJ8nd3e4QCyYT6r24F5EUnp/5ZZC1MFYzWDjg20NtwBQz+47Cg3BUZ3798iHpEBh9oGDnzpCKWefjVuiqNfmnoXw0X/MuJdVgVRofRxusdq9c07qQz3cMwbLDSXpI3DW1rUOJYqKzKGreKV4vPGWJP31d2QsRB7pLBnYh3EOS+Mxzn3EWrUo9HmMH+QRgJoIbe8rsdWDMY9TgDEGGmM4FdLKZ1yrmcw4YyJsE5v3ZWKk9gmDHDQoaxSI4Pz0s0uWaQMG0JIiraZhQXgtbOltjLWmsTFyE1dA46i/BHQuL4w==";
    ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHi4LaLvMfTamfV6iILdPgs3i8q5BhgyaigkPo3V/DZ";
  };
}
