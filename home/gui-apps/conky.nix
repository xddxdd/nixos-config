{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };

  verticalSize = 16;
  spaceSize = verticalSize / 2;
  alignX = 12;
  widthChars = 44;

  centerX = builtins.floor ((alignX + widthChars) / 2);
  alignRightCenter = widthChars - centerX;

  gray = content: "\${color grey}${content}$color";
  offset = n: "\${offset ${builtins.toString (n * spaceSize)}}";
  goto = n: "\${goto ${builtins.toString (n * spaceSize)}}";
  alignr = n: "\${alignr ${builtins.toString (n * spaceSize - 4)}}";

  padString = s: "${offset (alignX - lib.stringLength s)}${s}";

  fsUsage = path: ""
    + "\${if_mounted ${path}}"
    + "${gray (padString (path+":"))} \${fs_used_perc ${path}}% \$alignr \${fs_used ${path}} ${gray "/"} \${fs_size ${path}}\n"
    + "${offset alignX} \${fs_bar 4 ${path}}\n"
    + "\${endif}"
  ;
  netUsage = interface: ""
    + "\${if_up ${interface}}"
    + "${goto 0}${gray (padString (interface+":"))} ${gray "up:"} \${upspeed ${interface}}"
    + "${goto centerX}${gray "down:"} \${downspeed ${interface}}\n"
    + "\${endif}"
  ;
  processInfo = i:
    let
      n = builtins.toString i;
    in
    ""
    + " \${top name ${n}}${goto 20}\${top pid ${n}}${goto 28}\${top cpu ${n}}${goto 35}\${top mem ${n}}";

  conkyLines = [
    "${gray (padString "Hostname:")} $nodename"
    "${gray (padString "Kernel:")} $kernel"
    "${gray (padString "Arch:")} $machine"
    "${gray (padString "Load:")} ${gray "1m"} \${loadavg 1} ${gray "/ 5m"} \${loadavg 2} ${gray "/ 15m"} \${loadavg 3}"
    "${gray "$hr"}"
    "${gray (padString "CPU:")} $cpu% $alignr $freq_g GHz"
    "${offset alignX} \${cpubar 4}"
    "${gray (padString "RAM:")} $memperc% $alignr $mem ${gray "/"} $memmax"
    "${offset alignX} \${membar 4}"
    "${gray (padString "SWAP:")} $swapperc% $alignr $swap ${gray "/"} $swapmax"
    "${offset alignX} \${swapbar 4}"
    "${gray (padString "Battery:")} $battery_percent% $alignr $battery_time"
    "${offset alignX} \${battery_bar 4}"
    ("${gray (padString "GPU Power:")} \${head /sys/bus/pci/devices/0000:01:00.0/power_state 1}"
      + "${goto 0}${gray (padString "Processes:")} $running_processes ${gray "running /"} $processes ${gray "total"}")
    "${gray "$hr"}"
    "${gray "File systems:"}"
    ("${fsUsage "/"}"
      + "${fsUsage "/nix"}"
      + "${fsUsage "/mnt/c"}"
      + "${goto 0}${gray "$hr"}")
    "${gray "Networking:"}"
    ("${netUsage "eth0"}"
      + "${netUsage "wlan0"}"
      + "${netUsage "wg-lantian"}"
      + "${netUsage "wg-cf-warp"}"
      + "${goto 0}${gray "$hr"}")
    "${gray "Processes:"}${goto 20}${gray "    PID"}${goto 28}${gray "  CPU%"}${goto 35}${gray "  MEM%"}"
    "${processInfo 1}"
    "${processInfo 2}"
    "${processInfo 3}"
    "${processInfo 4}"
    "${processInfo 5}"
    "${processInfo 6}"
    "${processInfo 7}"
    "${processInfo 8}"
    "${processInfo 9}"
    "${processInfo 10}"
  ];
in
{
  xdg.configFile = (LT.autostart [
    ({ name = "conky"; command = "${pkgs.conky}/bin/conky --pause=1"; })
  ]) // {
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
      ${lib.concatStrings (builtins.map (s: "${goto 0}${s}\n") conkyLines)}
      ]]
    '';
  };
}
