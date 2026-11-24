#!/usr/bin/env bash
# Daftar app yang bisa dipilih untuk jendela mengambang (package | nama activity launcher)
. "$(dirname "$0")/env.sh"
adb shell pm query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>/dev/null | tr -d '\r' | grep '/' | sed 's#/.*##' | sort -u
