#!/usr/bin/env bash
set -euo pipefail
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-25.0.2.10-hotspot"

# Build script: compiles all modules with debug symbols, packages, signs, and installs APK.
# Save as /c/Apache24/htdocs/android/FFF_DARKCOMM2.sh and run.

BUILD="/c/Apache24/htdocs/android/build"
GLUE_C="/c/android-ndk-r27d/sources/android/native_app_glue/android_native_app_glue.c"
GLUE_INC="/c/android-ndk-r27d/sources/android/native_app_glue"

MANIFEST="$BUILD/AndroidManifest.xml"
AAPT2="/c/Android/Sdk/build-tools/34.0.0/aapt2.exe"
ZIPALIGN="/c/Android/Sdk/build-tools/34.0.0/zipalign.exe"
APKSIGNER="/c/Android/Sdk/build-tools/34.0.0/apksigner.bat"
PLATFORM_JAR="/c/Android/Sdk/platforms/android-34/android.jar"

CLANG_ARM64="/c/android-ndk-r27d/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android33-clang"
CLANG_X86_64="/c/android-ndk-r27d/toolchains/llvm/prebuilt/windows-x86_64/bin/x86_64-linux-android33-clang"

# Source files (native_app_glue + project modules)
SRC_FILES=(
  "$GLUE_C"
  "/c/Apache24/htdocs/android/index.c"
  "/c/Apache24/htdocs/android/drawmod.c"
  "/c/Apache24/htdocs/android/ui_mod.c"
  "/c/Apache24/htdocs/android/yc_log.c"
  "/c/Apache24/htdocs/android/avis.c"
)

# Debug flags for easier crash diagnosis
CFLAGS="-g -O0 -fno-omit-frame-pointer"

echo "[AVIS] ANDROID NATIVE C APK BUILDER INITIALIZED (debug build)"

# clean/create
/usr/bin/rm -rf "$BUILD"
/usr/bin/mkdir -p "$BUILD/lib/arm64-v8a"
/usr/bin/mkdir -p "$BUILD/lib/x86_64"

# Compile ARM64
echo "[AVIS] COMPILING ARM64 → libindex.so"
"$CLANG_ARM64" -shared -fPIC ${CFLAGS} -I "$GLUE_INC" -o "$BUILD/lib/arm64-v8a/libindex.so" "${SRC_FILES[@]}" -lEGL -lGLESv2 -llog -landroid

# Compile X86_64
echo "[AVIS] COMPILING X86_64 → libindex.so"
"$CLANG_X86_64" -shared -fPIC ${CFLAGS} -I "$GLUE_INC" -o "$BUILD/lib/x86_64/libindex.so" "${SRC_FILES[@]}" -lEGL -lGLESv2 -llog -landroid

# Write manifest (package and label)
echo "[AVIS] GENERATING AndroidManifest.xml"
cat > "$MANIFEST" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.josephm.catalano">

    <uses-sdk
        android:minSdkVersion="23"
        android:targetSdkVersion="34" />

    <application android:hasCode="false">
        <activity android:name="android.app.NativeActivity"
            android:label="Joseph M. Catalano"
            android:exported="true">

            <meta-data android:name="android.app.lib_name"
                android:value="index" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

        </activity>
    </application>
</manifest>
EOF

# Package resources (link)
echo "[AVIS] PACKAGING RESOURCES"
"$AAPT2" link -o "$BUILD/base.apk" --manifest "$MANIFEST" -I "$PLATFORM_JAR" --auto-add-overlay

# Add native libraries into APK
echo "[AVIS] ADDING NATIVE LIBRARIES TO APK"
(
  cd "$BUILD"
  /usr/bin/zip -r "base.apk" "lib"
)

# Align APK
echo "[AVIS] ALIGNING APK"
"$ZIPALIGN" -f 4 "$BUILD/base.apk" "$BUILD/aligned.apk"

# Sign APK (create debug keystore if missing)
echo "[AVIS] SIGNING APK"
KEYSTORE="$BUILD/debug.keystore"
if [ ! -f "$KEYSTORE" ]; then
  "/c/Program Files/Eclipse Adoptium/jdk-25.0.2.10-hotspot/bin/keytool.exe" -genkeypair -v \
    -keystore "$KEYSTORE" -storepass android -keypass android -alias androiddebugkey \
    -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Joseph M. Catalano,O=YCYBORG,C=US"
fi

"$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android --out "$BUILD/app.apk" "$BUILD/aligned.apk"

echo "[AVIS] INSTALLING APK"
/c/Android/Sdk/platform-tools/adb.exe install -r "$BUILD/app.apk"

echo "[AVIS] APK BUILD + INSTALL COMPLETE"
