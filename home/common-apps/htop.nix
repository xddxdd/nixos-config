{ lib, config, ... }:
{
  programs.htop = {
    enable = true;
    settings =
      {
        hide_kernel_threads = 0;
        hide_userland_threads = 1;
        show_thread_names = 1;
        show_program_path = 1;
        find_comm_in_cmdline = 1;
        strip_exe_from_cmdline = 1;
        sort_key = config.lib.htop.fields.PERCENT_CPU;
        sort_direction = -1;

        fields = with config.lib.htop.fields; [
          PID
          USER
          PRIORITY
          NICE
          M_SIZE
          M_RESIDENT
          M_SHARE
          STATE
          PERCENT_CPU
          PERCENT_MEM
          TIME
          COMM
        ];
      }
      // (
        with config.lib.htop;
        leftMeters [
          (bar "LeftCPUs2")
          (bar "Memory")
          (bar "Swap")
          (text "DiskIO")
          (text "NetworkIO")
        ]
      )
      // (
        with config.lib.htop;
        rightMeters [
          (bar "RightCPUs2")
          (text "Blank")
          (text "Tasks")
          (text "LoadAverage")
          (text "Systemd")
        ]
      );
  };
}
