{ pkgs, config, ... }:
{
  systemd.services.smfc = {
    description = "Super Micro Fan Control";
    wantedBy = [ "multi-user.target" ];
    after = [ "nvidia-tempmon.service" ];
    requires = [ "nvidia-tempmon.service" ];
    path = with pkgs; [
      python3
      ipmitool
    ];

    script = ''
      # Workaround issue of setting fan to max on startup
      timeout 10 python3 ${./smfc.py} -c ${./smfc.conf} -l 3 || true
      exec python3 ${./smfc.py} -c ${./smfc.conf} -l 3
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      ProcSubset = "all";
      ProtectKernelTunables = false;
    };
  };

  systemd.services.nvidia-tempmon = {
    description = "Monitor NVIDIA GPU temperature";
    wantedBy = [ "multi-user.target" ];
    path = [
      config.hardware.nvidia.package
    ];
    script = ''
      while true; do
        for i in $(seq 0 1); do
          echo $(nvidia-smi -q -i "$i" | grep "GPU Current Temp" | grep -E -o "[0-9]+" | sort -rn | head -n1)000 > /run/nvidia-tempmon/tmp$i
          mv /run/nvidia-tempmon/tmp$i /run/nvidia-tempmon/gpu$i
        done
        sleep 2
      done
    '';

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "3";

      RuntimeDirectory = "nvidia-tempmon";
    };
  };
}
