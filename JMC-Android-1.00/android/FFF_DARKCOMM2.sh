#!/usr/bin/env bash
set -euo pipefail
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-25.0.2.10-hotspot"

BUILD="/c/Apache24/htdocs/android/build"
SRC_C="/c/Apache24/htdocs/android/index.c"
GLUE_C="/c/android-ndk-r27d/sources/android/native_app_glue/android_native_app_glue.c"
GLUE_INC="/c/android-ndk-r27d/sources/android/native_app_glue"

MANIFEST="$BUILD/AndroidManifest.xml"
AAPT2="/c/Android/Sdk/build-tools/34.0.0/aapt2.exe"
ZIPALIGN="/c/Android/Sdk/build-tools/34.0.0/zipalign.exe"
APKSIGNER="/c/Android/Sdk/build-tools/34.0.0/apksigner.bat"
PLATFORM_JAR="/c/Android/Sdk/platforms/android-34/android.jar"

CLANG_ARM64="/c/android-ndk-r27d/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android33-clang"
CLANG_X86_64="/c/android-ndk-r27d/toolchains/llvm/prebuilt/windows-x86_64/bin/x86_64-linux-android33-clang"

# clean/create
/usr/bin/rm -rf "$BUILD"
/usr/bin/mkdir -p "$BUILD/lib/arm64-v8a"
/usr/bin/mkdir -p "$BUILD/lib/x86_64"

# compile list (all new modules)
SRC_FILES=(
    "$GLUE_C"
    "/c/Apache24/htdocs/android/index.c"
    "/c/Apache24/htdocs/android/drawmod.c"
    "/c/Apache24/htdocs/android/ui_mod.c"
    "/c/Apache24/htdocs/android/yc_log.c"
)

echo "[AVIS] COMPILING ARM64 → libindex.so"
"$CLANG_ARM64" -shared -fPIC -I "$GLUE_INC" -o "$BUILD/lib/arm64-v8a/libindex.so" "${SRC_FILES[@]}" -lEGL -lGLESv2 -llog -landroid

echo "[AVIS] COMPILING X86_64 → libindex.so"
"$CLANG_X86_64" -shared -fPIC -I "$GLUE_INC" -o "$BUILD/lib/x86_64/libindex.so" "${SRC_FILES[@]}" -lEGL -lGLESv2 -llog -landroid

# manifest (package and label kept as requested earlier)
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

# package, add libs, align, sign, install (same as before)
"$AAPT2" link -o "$BUILD/base.apk" --manifest "$MANIFEST" -I "$PLATFORM_JAR" --auto-add-overlay
(
  cd "$BUILD"
  /usr/bin/zip -r "base.apk" "lib"
)
"$ZIPALIGN" -f 4 "$BUILD/base.apk" "$BUILD/aligned.apk"

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
