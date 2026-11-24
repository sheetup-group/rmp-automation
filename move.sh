#!/usr/bin/env bash
# Geser / ubah ukuran jendela mengambang.
# Pakai: ./move.sh <package> to <x> <y>        pindah sudut kiri-atas ke x,y (ukuran tetap)
#        ./move.sh <package> by <dx> <dy>      geser relatif (piksel)
#        ./move.sh <package> size <lebar> <tinggi>
#        ./move.sh <package> full              kembalikan ke layar penuh
set -euo pipefail
. "$(dirname "$0")/env.sh"
PKG="${1:?package}"; CMD="${2:?to|by|size|full}"; A="${3:-0}"; B="${4:-0}"
DUMP="$(adb shell dumpsys activity activities)"
TID="$(echo "$DUMP" | grep -oE "Task\{[0-9a-f]+ #[0-9]+ type=standard A=[0-9]+:$PKG" | head -1 | sed -E 's/.*#([0-9]+) .*/\1/')"
[ -n "$TID" ] || { echo "Task $PKG tidak berjalan. Jalankan ./float.sh $PKG dulu."; exit 1; }
if [ "$CMD" = full ]; then adb shell cmd activity task set-windowing-mode "$TID" 1 >/dev/null 2>&1 || adb shell am start --windowingMode 1 -n "$(adb shell cmd package resolve-activity --brief -c android.intent.category.LAUNCHER "$PKG" | tail -1 | tr -d '\r')" >/dev/null; exit 0; fi
R="$(echo "$DUMP" | grep -A25 "#$TID type=standard A=[0-9]*:$PKG" | grep -oE "mBounds=Rect\([0-9-]+, [0-9-]+ - [0-9-]+, [0-9-]+\)" | head -1 | grep -oE "[0-9]+" | tr '\n' ' ')"
set -- $R; L=$1; T=$2; RR=$3; BB=$4; W=$((RR-L)); H=$((BB-T))
case "$CMD" in
  to)   L=$A; T=$B; RR=$((L+W)); BB=$((T+H)) ;;
  by)   L=$((L+A)); T=$((T+B)); RR=$((RR+A)); BB=$((BB+B)) ;;
  size) RR=$((L+A)); BB=$((T+B)) ;;
esac
adb shell cmd activity task resize "$TID" "$L" "$T" "$RR" "$BB"
echo "$PKG -> $L,$T - $RR,$BB"
