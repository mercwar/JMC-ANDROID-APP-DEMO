# FFF Android Demo Application 
#### JMC Edition BY DEMONIZER THE CVBGOD
![jmc](https://github.com/mercwar/Robo-Knight-Gallery/blob/main/Version%204/Copilot_20260322_040208.png)

### COPYWRITE © FFF DARKCOMM / MERCWAR SYSTEMS — ALL RIGHTS RESERVED

This repository contains the Android Native‑C Demo Application used by the MERCWAR / FFF toolchain for validating runtime pipelines, renderer stability, and Fire‑Gem command integration. This is NOT the OS, NOT the emulator, and NOT the AVIS core — this is the demo app that proves your Android native stack is functioning.

---

## Overview
The MERCWAR Android Demo App is a minimal, surgical native‑C renderer designed to validate:

- Clang compilation  
- NativeActivity pipeline  
- EGL + GLES initialization  
- Touch event forwarding  
- EXIT‑path correctness  
- Fire‑Gem macro execution (optional)  
- AVIS registry posting (optional)

This demo is intentionally small, explicit, and clone‑friendly so you can drop it into any environment and immediately confirm your Android native stack is functioning.

---

## Features

### Native Renderer
- EGL surface creation  
- Green background frame  
- ASCII‑style window border  
- Pixel‑drawn glyphs (R, K, etc.)  
- Software EXIT button  

### Touch Input
- Java → Native event forwarding  
- EXIT button hit‑test  
- Optional AVIS registry post  
- Clean shutdown callback  

### Minimal Java Layer
- Loads `libindex.so`  
- Creates GLSurfaceView  
- Forwards touch events  
- Calls `nativeOnExit()`  

No permissions. No network. No storage. Pure native.

---

## Project Layout
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

## Getting Started (Clone‑Ready)

### 1. Clone the Repository
```
git clone https://github.com/mercwar/fff-android-demo.git
cd fff-android-demo/android
```

### 2. Build the Native Demo
```
./FFF_DARKCOMM2.sh
```

### 3. Launch the Emulator
```
./run_android.sh
```

### 4. Install & Run
```
adb install -r build/app.apk
adb shell am start -n com.demo/.MainActivity
```

---

## Controls
- Tap anywhere → no action  
- Tap EXIT → clean shutdown  
- Touch events → logged to terminal (if AVIS logging enabled)

---

## Troubleshooting

### Black Screen
- Emulator must support GLES 2.0+  
- Ensure `libindex.so` exists in correct ABI folder  

### App Closes Immediately
- Check `adb logcat`  
- Verify manifest package name  

### Touch Not Working
- Ensure Activity forwards `onTouchEvent`  
- Confirm EXIT button region matches your resolution  

---

## Extending the Demo
This demo is the seed for:

- Fire‑Gem command receivers  
- Native UI widgets  
- Multi‑window runtimes  
- Remote‑controlled playback  
- Full AVIS integration  
- MERCWAR runtime modules  

---

## COPYWRITE
© FFF DARKCOMM / MERCWAR SYSTEMS  
All rights reserved.  
Internal development artifact — distribution restricted.



# CYBORG Projects — MERCWAR Edition

### COPYWRITE © FFF DARKCOMM / MERCWAR SYSTEMS — ALL RIGHTS RESERVED

This repository contains the official CYBORG project suite used by MERCWAR / FFF systems to explore, filter, and operate on directory structures, AVIS artifacts, and Fire‑Gem modules. This is the **project explorer**, not the runtime, not the OS, and not the emulator.

---

## Overview
CYBORG is a modular, AVIS‑compliant directory scanner and artifact explorer. It reads file trees, filters content by type, size, and extension, and prepares structured inputs for Fire‑Gem, AVIS, and macro‑driven pipelines.

It is designed for:
- directory scanning  
- file filtering  
- AVIS artifact detection  
- macro input preparation  
- registry‑driven project loading  

---

## Features

### Directory Scanner
- Reads root paths recursively  
- Detects folders, files, and symbolic links  
- Supports exclusion masks and depth limits  

### Filter Engine
- Filters by extension: `.c`, `.h`, `.txt`, `.avis`, `.dat`  
- Filters by size: `> 1MB`, `> 10MB`, `> 100MB`  
- Filters by type: folders only, files only, mixed  

### Project Explorer UI
- Displays filtered results in a holographic interface  
- Highlights AVIS artifacts and macro‑ready files  
- Allows manual selection and override  

### Registry Integration
- Posts selected paths to AVIS registry  
- Supports macro injection and Fire‑Gem boot sequences  

---

## Project Layout
```
cyborg/
│
├── cyborg.c              # main scanner + filter logic
├── cyborg_ui.c/.h        # holographic explorer interface
├── cyborg_registry.c     # AVIS registry integration
├── cyborg_macro.c        # macro prep + injection
│
├── config.ini            # filter rules + UI layout
├── cyborg_launcher.bat   # Windows launcher
├── cyborg_scan.sh        # Linux/Mac scan script
├── README.md             # this file
└── LICENSE               # MERCWAR license block
```

---

## Getting Started

### 1. Clone the Repository
```
git clone https://github.com/mercwar/cyborg.git
cd cyborg
```

### 2. Configure Filters
Edit `config.ini` to set:
- root path  
- file types  
- size limits  
- AVIS mode  

### 3. Launch the Explorer
```
./cyborg_scan.sh
```
Or on Windows:
```
cyborg_launcher.bat
```

---

## Output
- Filtered file list  
- AVIS artifact map  
- Macro‑ready file queue  
- Registry post confirmation  

---

## Extending CYBORG
CYBORG is designed to be extended into:
- full AVIS project loaders  
- macro‑driven batch runners  
- Fire‑Gem input pipelines  
- multi‑window holographic explorers  
- remote‑controlled scan agents  

---

## COPYWRITE
© FFF DARKCOMM / MERCWAR SYSTEMS  
All rights reserved.  
Internal development artifact — distribution restricted.

