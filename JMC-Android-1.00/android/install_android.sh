#!/usr/bin/env bash
set -euo pipefail

echo "[AVIS] ANDROID SDK INSTALLER INITIALIZED"

# Bash-style path
SDK_ROOT="/c/Android/Sdk"

# Windows-style paths for cmd.exe
WIN_CMD_TOOLS="C:\\Android\\Sdk\\cmdline-tools\\latest\\bin"

# Bash-style path for checks
CMD_TOOLS="$SDK_ROOT/cmdline-tools/latest/bin"

export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$PATH:$CMD_TOOLS"

echo "[AVIS] VERIFYING TOOLCHAIN PATH..."
echo "CMD_TOOLS = $CMD_TOOLS"

# Check for sdkmanager.bat
if [ ! -f "$CMD_TOOLS/sdkmanager.bat" ]; then
    echo "[AVIS] ERROR: sdkmanager NOT FOUND IN:"
    echo "       $CMD_TOOLS"
    exit 1
fi

echo "[AVIS] INSTALLING ANDROID COMPONENTS..."
cmd.exe /c "cd /d $WIN_CMD_TOOLS && sdkmanager.bat --install platform-tools emulator \"system-images;android-30;google_apis;x86_64\""

echo "[AVIS] CHECKING FOR EXISTING AVD..."
if ! ls ~/.android/avd/avis_emulator.avd >/dev/null 2>&1; then
    echo "[AVIS] CREATING AVD..."
    cmd.exe /c "cd /d $WIN_CMD_TOOLS && avdmanager.bat create avd -n avis_emulator -k \"system-images;android-30;google_apis;x86_64\" --device pixel"
fi

echo "[AVIS] ANDROID SDK INSTALLATION COMPLETE"
echo "[AVIS] LAUNCH WITH:"
echo "       $SDK_ROOT/emulator/emulator -avd avis_emulator"

echo "[AVIS] INSTALLER TERMINATED"
