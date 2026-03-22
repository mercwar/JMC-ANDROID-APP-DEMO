#!/usr/bin/env bash
# FILE: run_android.sh
# Launch the AVIS Android emulator

/c/Android/Sdk/emulator/emulator -avd avis_emulator
/usr/bin/bash /c/Apache24/htdocs/android/FFF_DARKCOMM2.sh
