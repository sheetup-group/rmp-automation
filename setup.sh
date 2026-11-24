#!/usr/bin/env bash
# Setup Android emulator tanpa Android Studio (macOS). Idempotent: aman dijalankan ulang.
set -euo pipefail

API="${API:-34}"
AVD_NAME="${AVD_NAME:-test_avd}"
DEVICE="${DEVICE:-pixel_6}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

case "$(uname -m)" in
  arm64|aarch64) ABI="arm64-v8a" ;;
  x86_64)        ABI="x86_64" ;;
  *) echo "Arsitektur tidak didukung"; exit 1 ;;
esac
IMAGE="system-images;android-${API};google_apis_playstore;${ABI}"

# 1. JDK 17 (via brew, tanpa sudo)
if ! /usr/libexec/java_home -v 17 >/dev/null 2>&1 && [ ! -d /opt/homebrew/opt/openjdk@17 ]; then
  brew install openjdk@17
fi
if [ -d /opt/homebrew/opt/openjdk@17 ]; then export JAVA_HOME=/opt/homebrew/opt/openjdk@17; fi
export PATH="$JAVA_HOME/bin:$PATH"

# 2. Command-line tools
if ! command -v sdkmanager >/dev/null 2>&1; then
  brew install --cask android-commandlinetools
fi
SDKM="$(command -v sdkmanager)"
# avdmanager menentukan SDK root dari lokasi aslinya, jadi salin (bukan symlink) ke SDK kita
if [ ! -x "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/avdmanager" ]; then
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
  cp -R /opt/homebrew/share/android-commandlinetools/cmdline-tools/latest "$ANDROID_SDK_ROOT/cmdline-tools/latest"
fi
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

# 3. Paket SDK
yes | "$SDKM" --sdk_root="$ANDROID_SDK_ROOT" --licenses >/dev/null || true
"$SDKM" --sdk_root="$ANDROID_SDK_ROOT" "platform-tools" "emulator" "platforms;android-${API}" "$IMAGE"

export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

# 4. AVD + kamera virtual
if ! avdmanager list avd 2>/dev/null | grep -q "Name: ${AVD_NAME}$"; then
  echo no | avdmanager create avd -n "$AVD_NAME" -k "$IMAGE" -d "$DEVICE"
fi
CFG="$HOME/.android/avd/${AVD_NAME}.avd/config.ini"
set_cfg() { grep -q "^$1=" "$CFG" && sed -i '' "s|^$1=.*|$1=$2|" "$CFG" || echo "$1=$2" >> "$CFG"; }
set_cfg hw.camera.back virtualscene
set_cfg hw.camera.front emulated
set_cfg hw.ramSize 2048
set_cfg disk.dataPartition.size 4G

echo "Selesai. AVD=$AVD_NAME image=$IMAGE"
echo "Tambahkan ke shell: export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
