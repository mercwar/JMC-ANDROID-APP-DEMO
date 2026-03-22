#!/usr/bin/env bash
set -euo pipefail

# --- FIX JAVA_HOME ---
export JAVA_HOME="/c/android-ndk-r27d/java"
export PATH="$JAVA_HOME/bin:$PATH"
# ---------------------

echo "[AVIS] ANDROID SDK INSTALLER INITIALIZED"

SDK_ROOT="/c/Android/Sdk"

echo "[AVIS] VERIFYING TOOLCHAIN PATH..."
echo "CMD_TOOLS = $SDK_ROOT/cmdline-tools/latest/bin"

echo "[AVIS] INSTALLING ANDROID COMPONENTS..."
cmd.exe /c C:\Apache24\htdocs\android\run_sdkmanager.cmd
