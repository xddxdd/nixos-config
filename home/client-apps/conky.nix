{
  pkgs,
  lib,
  LT,
  ...
}:
let
  verticalSize = 16;
  spaceSize = verticalSize / 2;
  alignX = 11;
  widthChars = 40;

  centerX = builtins.floor ((alignX + widthChars) / 2);

  gray = content: "\${color grey}${content}$color";
  offset = n: "\${offset ${builtins.toString (n * spaceSize)}}";
  goto = n: "\${goto ${builtins.toString (n * spaceSize)}}";

  padString = s: "${offset (alignX - lib.stringLength s)}${s}";

  fsUsage =
    path:
    ""
    + "\${if_mounted ${path}}"
    + (kv path "\${fs_used_perc ${path}}% \$alignr \${fs_used ${path}} ${gray "/"} \${fs_size ${path}}")
    + (kv "" "\${fs_bar 4 ${path}}")
    + "\${endif}";
  netGateway = "" + "\${if_gw}" + (kv "Gateway" "$gw_ip ${gray "%"} $gw_iface") + "\${endif}";
  netUsage =
    interface:
    ""
    + "\${if_up ${interface}}"
    + (kv interface "${gray "IP:"} \${addrs ${interface}}")
    + (kv "" "${gray "up:"} \${upspeed ${interface}}${goto centerX}${gray "down:"} \${downspeed ${interface}}")
    + "\${endif}";
  processInfo =
    i:
    let
      n = builtins.toString i;
    in
    "${reset}${gray "\${top name ${n}}"}${goto 20}\${top pid ${n}}${goto 28}\${top cpu ${n}}${goto 35}\${top mem ${n}}\n";

  kv = k: v: "${reset}${kvNoLF k v}\n";
  kvNoLF = k: v: "${reset}${gray (padString (if k != "" then k + ":" else ""))} ${v}";
  sep = "${reset}${gray "$hr"}\n";
  reset = "${goto 0}";

  conkyLines = lib.flatten [
    (kv "Hostname" "$nodename")
    (kv "Kernel" "$kernel")
    (kv "Arch" "$machine")
    (kv "Load" "${gray "1m"} \${loadavg 1} ${gray "/ 5m"} \${loadavg 2} ${gray "/ 15m"} \${loadavg 3}")
    sep

    (kv "CPU" "$cpu% $alignr $freq_g GHz")
    (kv "" "\${cpubar 4}")
    (kv "RAM" "$memperc% $alignr $mem ${gray "/"} $memmax")
    (kv "" "\${membar 4}")
    (kv "SWAP" "$swapperc% $alignr $swap ${gray "/"} $swapmax")
    (kv "" "\${swapbar 4}")
    (kv "Battery" "$battery_percent% $alignr $battery_time")
    (kv "" "\${battery_bar 4}")
    (
      "\${if_existing /sys/bus/pci/devices/0000:01:00.0/power_state}"
      + (kvNoLF "GPU Power" "\${head /sys/bus/pci/devices/0000:01:00.0/power_state 1}")
      + "\${endif}"
    )
    (kv "Processes" "$running_processes ${gray "running /"} $processes ${gray "total"}")
    (kv "Threads" "$running_threads ${gray "running /"} $threads ${gray "total"}")
    sep

    (builtins.map fsUsage [
      "/"
      "/nix"
      "/mnt/c"
    ])
    sep

    netGateway
    (builtins.map netUsage [
      "eth0"
      "wlan0"
    ])
    sep

    "${reset}${goto 24}${gray "PID"}${goto 30}${gray "CPU%"}${goto 37}${gray "MEM%"}\n"
    (builtins.map processInfo (lib.range 1 10))
  ];
in
{
  xdg.configFile =
    (LT.gui.autostart [
      {
        name = "conky";
        command = "${pkgs.conky}/bin/conky --pause=5";
      }
    ])
    // {
      "conky/conky.conf".text = ''
        conky.config = {
          alignment = 'top_right',
          background = false,
          border_width = 0,
          cpu_avg_samples = 2,
          default_color = 'white',
          default_outline_color = 'white',
          default_shade_color = 'white',
          double_buffer = true,
          draw_borders = false,
          draw_graph_borders = true,
          draw_outline = false,
          draw_shades = false,
          extra_newline = false,
          font = 'Ubuntu Mono:size=12',
          gap_x = 10,
          gap_y = 40,
          minimum_height = 5,
          minimum_width = ${builtins.toString (widthChars * spaceSize)},
          net_avg_samples = 2,
          no_buffers = true,
          out_to_console = false,
          out_to_ncurses = false,
          out_to_stderr = false,
          out_to_x = true,
          own_window = true,
          own_window_argb_visual = true,
          own_window_class = 'Conky',
          own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
          own_window_transparent = true,
          own_window_type = 'normal',
          show_graph_range = false,
          show_graph_scale = false,
          stippled_borders = 0,
          update_interval = 1.0,
          uppercase = false,
          use_spacer = 'none',
          use_xft = true,
        }

        conky.text = [[
        ${lib.concatStrings conkyLines}
        ]]
      '';
    };
}
