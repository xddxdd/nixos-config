#!/usr/bin/env bash

ping_target() {
  local output
  output=$(timeout 10 "$BASH" -c 'ping -n -c 5 "$@" || :' -- "$@" 2>/dev/null) || return 1
  [[ $output =~ rtt\ min/avg/max/mdev\ =\ ([0-9]+\.?[0-9]*)/([0-9]+\.?[0-9]*)/([0-9]+\.?[0-9]*)/([0-9]+\.?[0-9]*)\ ms ]] || return 1
  # Match Python round(): exact half milliseconds round to the even integer.
  LC_ALL=C awk -v avg="${BASH_REMATCH[2]}" 'BEGIN {
    n = int(avg)
    printf "%.0f", n + (avg - n > 0.5 || (avg - n == 0.5 && n % 2 == 1))
  }'
}
