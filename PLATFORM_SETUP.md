# JBRC - Multi-Platform Setup Guide

## ✅ What Has Been Configured

Your Flutter app has been successfully configured to run on **all platforms**:
- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Windows

### Changes Made:

1. **App Icons & Splash Screens**
   - Updated `pubspec.yaml` with `flutter_launcher_icons` and `flutter_native_splash`
   - Generated launcher icons for all platforms
   - Generated native splash screens for Android and iOS
   - Fixed logo consistency across all platforms (using `assets/logo.png`)

2. **App Name Consistency**
   - Android: "JBRC" (AndroidManifest.xml)
   - iOS: "JBRC" (Info.plist)
   - macOS: "JBRC" (Info.plist)
   - Windows: "JBRC" (main.cpp)

3. **Permissions Configuration**
   - iOS: Added camera, photo library, location, and contacts permissions
   - macOS: Added entitlements for camera, photos, files, location, and contacts
   - Android: Already configured with all necessary permissions

4. **Platform-Specific Configurations**
   - Android 12+ splash screen support
   - iOS status bar configuration
   - macOS sandboxing with proper entitlements
   - Windows window configuration

---

## 🚀 How to Run on Each Platform

### 📱 **Android**

#### Prerequisites:
1. Install Android Studio
2. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```
3. Set up an Android emulator or connect a physical device

#### Run:
```bash
# Start an emulator
flutter emulators --launch <emulator_id>

# Or connect a physical device and run:
flutter run -d <device_id>

# Or to automatically select Android device:
flutter run -d android
```

#### Build APK:
```bash
flutter build apk --release
```

#### Build App Bundle (for Google Play):
```bash
flutter build appbundle --release
```

---

### 🍎 **iOS**

#### Prerequisites:
1. **Install Xcode** (from App Store or [developer.apple.com](https://developer.apple.com/xcode/))
2. Run these commands after Xcode installation:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
3. **Install CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```
4. Install iOS dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```

#### Run:
```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run -d ios

# Or specify a specific simulator
flutter run -d "iPhone 15 Pro"
```

#### Build IPA:
```bash
flutter build ipa --release
```

---

### 💻 **macOS**

#### Prerequisites:
1. **Install Xcode** (same as iOS requirements)
2. Install CocoaPods (same as iOS)
3. Install macOS dependencies:
   ```bash
   cd macos
   pod install
   cd ..
   ```

#### Run:
```bash
flutter run -d macos
```

#### Build macOS App:
```bash
flutter build macos --release
```

The app will be in: `build/macos/Build/Products/Release/JBRC.app`

---

### 🪟 **Windows**

#### Prerequisites:
1. **Visual Studio 2022** with "Desktop development with C++"
   - Download from [visualstudio.microsoft.com](https://visualstudio.microsoft.com/)
   - During installation, select "Desktop development with C++" workload

#### Run:
```bash
flutter run -d windows
```

#### Build Windows App:
```bash
flutter build windows --release
```

The app will be in: `build/windows/x64/runner/Release/`

---

## 🛠️ Common Commands

### Check Platform Support:
```bash
flutter doctor
flutter doctor -v  # Verbose output
```

### List Available Devices:
```bash
flutter devices
```

### List Available Emulators:
```bash
flutter emulators
```

### Clean and Rebuild:
```bash
flutter clean
flutter pub get
```

### Regenerate Icons (if needed):
```bash
dart run flutter_launcher_icons
```

### Regenerate Splash Screens (if needed):
```bash
dart run flutter_native_splash:create
```

---

## 📝 Platform-Specific Notes

### Android
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 35 (Android 15)
- Firebase is configured (google-services.json present)
- Adaptive icons configured for modern Android versions

### iOS
- **Minimum iOS Version**: 12.0
- Requires Apple Developer account for physical device testing
- CocoaPods required for dependency management
- All necessary permissions are configured in Info.plist

### macOS
- **Minimum macOS Version**: 10.15
- App sandboxing is enabled with necessary entitlements
- Network, camera, photos, and location permissions configured
- JIT compilation enabled for debug builds

### Windows
- **Minimum Windows Version**: Windows 10
- Requires Visual Studio 2022 or later
- Window size: 1280x720 (default)

---

## 🔧 Troubleshooting

### Icons Not Showing Correctly?
```bash
flutter clean
dart run flutter_launcher_icons
flutter pub get
flutter run
```

### Splash Screen Issues?
```bash
flutter clean
dart run flutter_native_splash:create
flutter pub get
flutter run
```

### iOS/macOS Build Errors?
```bash
cd ios  # or cd macos
pod deintegrate
pod install
cd ..
flutter clean
flutter run -d ios  # or -d macos
```

### Android Build Errors?
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run -d android
```

### Windows Build Errors?
- Ensure Visual Studio 2022 is installed with C++ development tools
- Run Visual Studio Installer and verify "Desktop development with C++" is checked

---

## 📱 Testing on Physical Devices

### Android:
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter devices` to verify
5. Run `flutter run`

### iOS:
1. Connect iPhone/iPad via USB
2. Trust the computer on your device
3. Open Xcode and sign the app with your Apple ID
4. Run `flutter run`

### macOS:
- No additional setup needed, runs directly on your Mac

### Windows:
- No additional setup needed, runs directly on your PC

---

## 🎨 Customizing Assets

### Change App Icon:
1. Replace `assets/logo.png` with your new icon (1024x1024 recommended)
2. Run: `dart run flutter_launcher_icons`

### Change Splash Screen:
1. Replace `assets/logo.png` with your splash image
2. Edit splash color in `pubspec.yaml` under `flutter_native_splash > color`
3. Run: `dart run flutter_native_splash:create`

---

## 📦 Building for Release

### Android (Play Store):
```bash
flutter build appbundle --release
# Find at: build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store):
```bash
flutter build ipa --release
# Then upload via Xcode or Transporter app
```

### macOS (App Store):
```bash
flutter build macos --release
# Sign and package with Xcode
```

### Windows (Microsoft Store or Direct):
```bash
flutter build windows --release
# Package with MSIX or create installer
```

---

## ✅ Current Status

Your app is now ready to run on:
- ✅ Android (configured and working)
- ⚠️ iOS (needs Xcode and CocoaPods installation)
- ⚠️ macOS (needs Xcode and CocoaPods installation)
- ⚠️ Windows (needs Visual Studio 2022 with C++ tools)

**Next Steps:**
1. Install the required tools for your target platforms (see Prerequisites above)
2. Run `flutter doctor` to verify setup
3. Test on each platform using `flutter run -d <platform>`

---

## 📞 Support

If you encounter issues:
1. Run `flutter doctor -v` for detailed diagnostics
2. Check the specific platform section above
3. Refer to Flutter documentation: https://flutter.dev/docs

---

**App Name:** JBRC  
**Package:** com.jbrc  
**Version:** 1.0.0+1  
**Flutter Version:** 3.29.3  
