{ pkgs, ... }:
{
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    extraRules = [
      {
        name = "audacious";
        sched = "fifo";
        rtprio = 99;
        ioclass = "realtime";
      }
      {
        name = "pipewire";
        sched = "fifo";
        rtprio = 99;
        ioclass = "realtime";
      }
      {
        name = "pipewire-pulse";
        sched = "fifo";
        rtprio = 99;
        ioclass = "realtime";
      }
    ];
  };
}
