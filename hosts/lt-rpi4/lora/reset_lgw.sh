#!/usr/bin/env bash

# This script is intended to be used on SX1302 CoreCell platform, it performs
# the following actions:
#       - reset the SX1302 chip and to enable the LDOs
#       - reset the optional SX1261 radio used for LBT/Spectral Scan
#
# Usage examples:
#       ./reset_lgw.sh stop
#       ./reset_lgw.sh start

# GPIO mapping has to be adapted with HW
#
# Pin numbers are line offsets on the SoC GPIO chip, not the sysfs global
# numbers (which start at 512 for the same lines).
CHIP=gpiochip0

SX1302_RESET_PIN=25    # SX1302 reset
SX1302_POWER_EN_PIN=18 # SX1302 power enable
SX1261_RESET_PIN=22    # SX1261 reset (LBT / Spectral Scan)
AD5338R_RESET_PIN=13   # AD5338R reset (full-duplex CN490 reference design)

WAIT_GPIO() {
  sleep 0.1
}

# The GPIO character device is the only interface available: sysfs GPIO is
# gone (CONFIG_GPIO_SYSFS is unset). gpioset releases the line on exit but
# leaves the output latch at the requested value, so -t 0 makes it exit
# right after applying the value.
set_gpio() {
  gpioset -c "$CHIP" -t 0 "$1=$2"
}

reset() {
  echo "CoreCell reset through GPIO$SX1302_RESET_PIN..."
  echo "SX1261 reset through GPIO$SX1261_RESET_PIN..."
  echo "CoreCell power enable through GPIO$SX1302_POWER_EN_PIN..."
  echo "CoreCell ADC reset through GPIO$AD5338R_RESET_PIN..."

  # write output for SX1302 CoreCell power_enable and reset
  set_gpio $SX1302_POWER_EN_PIN 0
  WAIT_GPIO
  set_gpio $SX1302_POWER_EN_PIN 1
  WAIT_GPIO

  set_gpio $SX1302_RESET_PIN 1
  WAIT_GPIO
  set_gpio $SX1302_RESET_PIN 0
  WAIT_GPIO

  set_gpio $SX1261_RESET_PIN 0
  WAIT_GPIO
  set_gpio $SX1261_RESET_PIN 1
  WAIT_GPIO

  set_gpio $AD5338R_RESET_PIN 0
  WAIT_GPIO
  set_gpio $AD5338R_RESET_PIN 1
  WAIT_GPIO
}

term() {
  # hold the CoreCell in reset and switch it off
  set_gpio $SX1302_RESET_PIN 1
  WAIT_GPIO
  set_gpio $SX1302_POWER_EN_PIN 0
}

case "$1" in
start)
  reset
  ;;
stop)
  term
  ;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
  ;;
esac

exit 0
