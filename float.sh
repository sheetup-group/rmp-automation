#!/usr/bin/env bash
# Jendela mengambang SEMENTARA (tidak mengubah setting permanen selain 2 flag developer yang aman).
#   ./float.sh <package>                         buka mengambang (ukuran bawaan)
#   ./float.sh <package> kiri atas kanan bawah   buka dengan posisi/ukuran (piksel, layar 1080x2400)
#   ./float.sh <package> close                   tutup jendela itu
#   ./float.sh off                               tutup semua yang dibuka lewat float.sh
set -euo pipefail
. "$(dirname "$0")/env.sh"
STATE="${TMPDIR:-/tmp}/float_open.list"
if [ "${1:-}" = off ]; then
  [ -f "$STATE" ] && while read -r p; do adb shell am force-stop "$p"; done < "$STATE"; rm -f "$STATE"; echo "semua jendela mengambang ditutup"; exit 0
fi
PKG="${1:?package atau 'off'}"; shift || true
if [ "${1:-}" = close ]; then adb shell am force-stop "$PKG"; echo "$PKG ditutup"; exit 0; fi
adb shell settings put global enable_freeform_support 1
adb shell settings put global force_resizable_activities 1
ACT="$(adb shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER "$PKG" | tail -1 | tr -d '\r')"
case "$ACT" in */*) ;; *) echo "Activity launcher tidak ditemukan untuk $PKG"; exit 1;; esac
adb shell am start --windowingMode 5 -f 0x20000 -n "$ACT" >/dev/null
echo "$PKG" >> "$STATE"
if [ "$#" -eq 4 ]; then
  sleep 2
  TID="$(adb shell dumpsys activity activities | grep -oE "Task\{[0-9a-f]+ #[0-9]+ type=standard A=[0-9]+:$PKG" | head -1 | sed -E 's/.*#([0-9]+) .*/\1/')"
  [ -n "$TID" ] && adb shell cmd activity task resize "$TID" "$1" "$2" "$3" "$4"
fi
echo "Mengambang: $ACT"
