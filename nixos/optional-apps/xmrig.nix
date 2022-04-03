{ pkgs, lib, config, ... }:

let
  cfgFile = pkgs.writeText "xmrig.json" (builtins.toJSON {
    autosave = true;
    donate-level = 0;
    cpu = {
      enabled = true;
      huge-pages = true;
      huge-pages-jit = true;
    };
    opencl.enabled = false;
    cuda.enabled = false;
    randomx = {
      "1gb-pages" = true;
      rdmsr = true;
      wrmsr = true;
    };
    pools = [{
      url = "pool.supportxmr.com:443";
      user = "42k8RvF6Y8N6gGkhxYd653GnZynJbBJyR9cvw55CW31M4MAGtvE4HAd53AVpZ7VyywWShhQixb73Ycxv9EvtEbGv4bm29VC";
      pass = config.networking.hostName;
      keepalive = true;
      tls = true;
    }];
  });
in
{
  systemd.services.xmrig = {
    description = "XMRig";
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      After = "network.target";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";
      ExecStart = "${pkgs.xmrig}/bin/xmrig -c ${cfgFile}";
      Nice = "19";
    };
  };
  boot.kernelParams = [
    "default_hugepagesz=1G"
    "hugepagesz=1G"
    "hugepages=3"
    "mitigations=off"
  ];
}
