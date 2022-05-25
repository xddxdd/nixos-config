{ config, pkgs, lib, ... }:

let
  LT = import ../../helpers { inherit config pkgs lib; };
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
