#!/usr/bin/env bash
# Pengganti tombol toolbar emulator. Pakai: ./keys.sh home|back|recents|power|volup|voldown|rotate|shot [file.png]
. "$(dirname "$0")/env.sh"
case "${1:?perintah}" in
  home)    adb shell input keyevent KEYCODE_HOME ;;
  back)    adb shell input keyevent KEYCODE_BACK ;;
  recents) adb shell input keyevent KEYCODE_APP_SWITCH ;;
  power)   adb shell input keyevent KEYCODE_POWER ;;
  volup)   adb shell input keyevent KEYCODE_VOLUME_UP ;;
  voldown) adb shell input keyevent KEYCODE_VOLUME_DOWN ;;
  rotate)  adb emu rotate ;;
  shot)    adb exec-out screencap -p > "${2:-screenshot_$(date +%H%M%S).png}"; echo "tersimpan: ${2:-screenshot}" ;;
  *) echo "perintah tidak dikenal"; exit 1 ;;
esac
