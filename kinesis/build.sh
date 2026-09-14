#!/usr/bin/env bash
set -eu
west build -s zmk/app -p -d build/left -b adv360_left -S studio-rpc-usb-uart -- -DZMK_CONFIG=/app/config -DCONFIG_ZMK_STUDIO=y
cp build/left/zephyr/zmk.uf2 firmware/left.uf2
west build -s zmk/app -p -d build/right -b adv360_right -- -DZMK_CONFIG=/app/config
cp build/right/zephyr/zmk.uf2 firmware/right.uf2
