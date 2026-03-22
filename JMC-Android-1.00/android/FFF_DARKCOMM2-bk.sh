#!/usr/bin/env bash
set -euo pipefail
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-25.0.2.10-hotspot"

echo "[AVIS] ANDROID NATIVE C APK BUILDER INITIALIZED"

# ------------------------------------------------------------
# ABSOLUTE PATHS ONLY
# ------------------------------------------------------------

BUILD="/c/Apache24/htdocs/android/build"
SRC_C="/c/Apache24/htdocs/android/index.c"   # should implement android_main when using glue
GLUE_C="/c/android-ndk-r27d/sources/android/native_app_glue/android_native_app_glue.c"
GLUE_INC="/c/android-ndk-r27d/sources/android/native_app_glue"

MANIFEST="$BUILD/AndroidManifest.xml"

AAPT2="/c/Android/Sdk/build-tools/34.0.0/aapt2.exe"
ZIPALIGN="/c/Android/Sdk/build-tools/34.0.0/zipalign.exe"
APKSIGNER="/c/Android/Sdk/build-tools/34.0.0/apksigner.bat"
PLATFORM_JAR="/c/Android/Sdk/platforms/android-34/android.jar"

# Use API level 33+ toolchains for modern NDKs; adjust if needed
CLANG_ARM64="/c/android-ndk-r27d/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android33-clang"
CLANG_X86_64="/c/android-ndk-r27d/toolchains/llvm/prebuilt/windows-x86_64/bin/x86_64-linux-android33-clang"

# ------------------------------------------------------------
# CLEAN + CREATE DIRECTORIES
# ------------------------------------------------------------

/usr/bin/rm -rf "$BUILD"
/usr/bin/mkdir -p "$BUILD/lib/arm64-v8a"
/usr/bin/mkdir -p "$BUILD/lib/x86_64"

# ------------------------------------------------------------
# COMPILE C → libindex.so (ARM64 + X86_64)
# ------------------------------------------------------------
# Note: when compiling with the glue, your SRC_C must implement android_main
# and must NOT define ANativeActivity_onCreate (duplicate symbol otherwise).

echo "[AVIS] COMPILING ARM64 → libindex.so"
"$CLANG_ARM64" \
    -shared -fPIC \
    -I "$GLUE_INC" \
    -o "$BUILD/lib/arm64-v8a/libindex.so" \
    "$GLUE_C" \
    "$SRC_C" \
    -lEGL -lGLESv2 -llog -landroid

echo "[AVIS] COMPILING X86_64 → libindex.so"
"$CLANG_X86_64" \
    -shared -fPIC \
    -I "$GLUE_INC" \
    -o "$BUILD/lib/x86_64/libindex.so" \
    "$GLUE_C" \
    "$SRC_C" \
    -lEGL -lGLESv2 -llog -landroid

# ------------------------------------------------------------
# WRITE MANIFEST
# ------------------------------------------------------------

echo "[AVIS] GENERATING AndroidManifest.xml"

cat > "$MANIFEST" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.nativeactivity">

    <uses-sdk
        android:minSdkVersion="23"
        android:targetSdkVersion="34" />

    <application android:hasCode="false">
        <activity android:name="android.app.NativeActivity"
            android:label="NativeActivity"
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

# ------------------------------------------------------------
# AAPT2: LINK ONLY
# ------------------------------------------------------------

echo "[AVIS] PACKAGING RESOURCES"

"$AAPT2" link \
    -o "$BUILD/base.apk" \
    --manifest "$MANIFEST" \
    -I "$PLATFORM_JAR" \
    --auto-add-overlay

# ------------------------------------------------------------
# ADD NATIVE LIBRARIES TO APK
# ------------------------------------------------------------

echo "[AVIS] ADDING NATIVE LIBRARIES TO APK"

(
    cd "$BUILD"
    /usr/bin/zip -r "base.apk" "lib"
)

# ------------------------------------------------------------
# ALIGN APK
# ------------------------------------------------------------

echo "[AVIS] ALIGNING APK"

"$ZIPALIGN" -f 4 \
    "$BUILD/base.apk" \
    "$BUILD/aligned.apk"

# ------------------------------------------------------------
# SIGN APK
# ------------------------------------------------------------

echo "[AVIS] SIGNING APK"

KEYSTORE="$BUILD/debug.keystore"

if [ ! -f "$KEYSTORE" ]; then
    "/c/Program Files/Eclipse Adoptium/jdk-25.0.2.10-hotspot/bin/keytool.exe" -genkeypair -v \
        -keystore "$KEYSTORE" \
        -storepass android \
        -keypass android \
        -alias androiddebugkey \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=AVIS,O=AVIS,C=US"
fi

"$APKSIGNER" sign \
    --ks "$KEYSTORE" \
    --ks-pass pass:android \
    --key-pass pass:android \
    --out "$BUILD/app.apk" \
    "$BUILD/aligned.apk"

echo "[AVIS] APK SIGNED → $BUILD/app.apk"

# ------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------

echo "[AVIS] INSTALLING APK TO DEVICE"

/c/Android/Sdk/platform-tools/adb.exe install -r "$BUILD/app.apk"

echo "[AVIS] APK BUILD + INSTALL COMPLETE"
