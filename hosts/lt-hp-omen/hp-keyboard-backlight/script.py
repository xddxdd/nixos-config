#!/usr/bin/env python
import os
import time

COLORS = [
    '03A9F4',
    'FFEB3B',
    'E53935',
]

COLORS = [(int(color[0:2], 16), int(color[2:4], 16), int(color[4:6], 16)) for color in COLORS]

def blend_color(color1: tuple[int], color2: tuple[int], color2_weight: float) -> tuple[int]:
    r1, g1, b1 = color1
    r2, g2, b2 = color2
    r = round(r1 * (1 - color2_weight) + r2 * color2_weight)
    g = round(g1 * (1 - color2_weight) + g2 * color2_weight)
    b = round(b1 * (1 - color2_weight) + b2 * color2_weight)
    return r, g, b

def set_color(color: tuple[int]) -> None:
    path = '/sys/devices/platform/hp-wmi/rgb_zones'

    # Skip if kernel module isn't initialized yet
    if not os.path.exists(path):
        return

    for zone in os.listdir(path):
        with open(os.path.join(path, zone), 'a') as f:
            f.write('%02x%02x%02x\n' % color)

if __name__ == "__main__":
    last_load = -1
    while True:
        load = max([os.getloadavg()[0] / os.cpu_count(), 0])
        # print(load)

        if load != last_load:
            last_load = load

            blend_idx = int(load)
            if blend_idx >= len(COLORS) - 1:
                result_color = COLORS[-1]
            else:
                result_color = blend_color(COLORS[blend_idx], COLORS[blend_idx + 1], load - blend_idx)

            # print(result_color)
            set_color(result_color)

        time.sleep(1)
