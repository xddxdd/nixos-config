{ LT, ... }:
{
  programs.htop = {
    enable = true;
    settings = {
      hide_kernel_threads = 0;
      hide_userland_threads = 1;
      show_thread_names = 1;
      show_program_path = 1;
      find_comm_in_cmdline = 1;
      strip_exe_from_cmdline = 1;
      sort_key = 46; # PERCENT_CPU
      sort_direction = -1;

      fields = [
        0 # PID
        48 # USER
        54 # SCHEDULERPOLICY
        18 # NICE
        39 # M_RESIDENT
        2 # STATE
        46 # PERCENT_CPU
        47 # PERCENT_MEM
        111 # IO_RATE
        116 # PERCENT_IO_DELAY
        117 # PERCENT_SWAP_DELAY
        1 # COMM
      ];

      left_meters = [
        (if LT.this.cpuThreads > 16 then "LeftCPUs4" else "LeftCPUs2")
        "Memory"
        "Swap"
        "DiskIO"
        "NetworkIO"
      ];
      left_meter_modes = [
        1
        1
        1
        2
        2
      ];
      right_meters = [
        (if LT.this.cpuThreads > 16 then "RightCPUs4" else "RightCPUs2")
        "Blank"
        "Tasks"
        "LoadAverage"
        "Systemd"
      ];
      right_meter_modes = [
        1
        2
        2
        2
        2
      ];
    };
  };
}
