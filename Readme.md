# **MERCWAR / FFF — Android Demo Application**
### **COPYWRITE © FFF DARKCOMM / MERCWAR SYSTEMS — ALL RIGHTS RESERVED**

This repository contains the **Android Native‑C Demo Application** used by the MERCWAR / FFF toolchain for validating runtime pipelines, renderer stability, and Fire‑Gem command integration.  
This is **NOT** the OS, **NOT** the emulator, and **NOT** the AVIS core — this is the **demo app** that proves your Android native path is alive.

---

# **Overview**
The MERCWAR Android Demo App is a **minimal, surgical native‑C renderer** designed to validate:

- Clang compilation  
- NativeActivity pipeline  
- EGL + GLES initialization  
- Touch event forwarding  
- EXIT‑path correctness  
- Fire‑Gem macro execution (optional)  
- AVIS registry posting (optional)

This demo is intentionally small, explicit, and clone‑friendly so you can drop it into any environment and immediately confirm your Android native stack is functioning.

---

# **Features**
### **Native Renderer**
- EGL surface creation  
- Green background frame  
- ASCII‑style window border  
- Pixel‑drawn glyphs (R, K, etc.)  
- Software EXIT button  

### **Touch Input**
- Java → Native event forwarding  
- EXIT button hit‑test  
- Optional AVIS registry post  
- Clean shutdown callback  

### **Minimal Java Layer**
- Loads `libindex.so`  
- Creates GLSurfaceView  
- Forwards touch events  
- Calls `nativeOnExit()`  

No permissions.  
No network.  
No storage.  
Pure native.

---

# **Project Layout**
```
android/
│
├── index.c              # Native renderer + event loop
├── avis.c               # Optional AVIS registry hooks
├── registry.c/.h        # Internal registry system
│
├── build/               # Output artifacts
│   ├── app.apk
│   ├── lib/arm64-v8a/libindex.so
│   └── lib/x86_64/libindex.so
│
├── FFF_DARKCOMM2.sh     # Build + sign + install script
├── run_android.sh       # Emulator runner
├── AndroidManifest.xml  # NativeActivity config
└── index_arm64          # Standalone native binary
```

---

# **Getting Started (Clone‑Ready)**

### **1. Clone the Repository**
```
git clone https://github.com/mercwar/fff-android-demo.git
cd fff-android-demo/android
```

*(Replace with your actual repo URL — this is a placeholder.)*

---

### **2. Build the Native Demo**
```
./FFF_DARKCOMM2.sh
```

This script:

- Compiles native C  
- Builds the APK  
- Signs it  
- Installs it to your emulator/device  

---

### **3. Launch the Emulator**
```
./run_android.sh
```

Or use Android Studio’s AVD Manager.

---

### **4. Install & Run**
If you want to reinstall manually:

```
adb install -r build/app.apk
adb shell am start -n com.demo/.MainActivity
```

---

# **Controls**
- Tap anywhere → no action  
- Tap EXIT → clean shutdown  
- Touch events → logged to terminal (if AVIS logging enabled)

---

# **Troubleshooting**
### **Black Screen**
- Emulator must support GLES 2.0+  
- Ensure `libindex.so` exists in correct ABI folder  

### **App Closes Immediately**
- Check `adb logcat`  
- Verify manifest package name  

### **Touch Not Working**
- Ensure Activity forwards `onTouchEvent`  
- Confirm EXIT button region matches your resolution  

---

# **Extending the Demo**
This demo is the seed for:

- Fire‑Gem command receivers  
- Native UI widgets  
- Multi‑window runtimes  
- Remote‑controlled playback  
- Full AVIS integration  
- MERCWAR runtime modules  

The renderer is intentionally simple so you can graft new systems onto it without friction.

---

# **COPYWRITE**
© **FFF DARKCOMM / MERCWAR SYSTEMS**  
All rights reserved.  
Internal development artifact — distribution restricted.

---
