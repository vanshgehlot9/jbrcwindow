# Logo & Splash Screen Configuration

## Current Setup ✅

Your app now has **consistent branding** across all platforms!

### App Icons
- **Source File**: `assets/logo.png`
- **Platforms**: Android, iOS, macOS, Windows
- **Status**: ✅ Generated and configured

### Splash Screens
- **Source File**: `assets/logo.png`
- **Background Color**: Black (#000000)
- **Platforms**: Android (including Android 12+), iOS
- **Status**: ✅ Generated and configured

---

## What Was Fixed

### Before ❌
- Android launcher icon was showing different from splash screen
- iOS icons were disabled
- No Windows/macOS launcher icons
- Inconsistent logo across platforms
- Splash screen using logo.jpeg instead of logo.png

### After ✅
- All platforms use the same `logo.png` file
- Launcher icons generated for **all platforms**
- Native splash screens for Android & iOS
- Consistent black background with centered logo
- Android 12+ splash screen support
- Adaptive icons for Android

---

## Generated Assets

### Android Icons
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png
├── mipmap-mdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
├── mipmap-xxxhdpi/ic_launcher.png
└── mipmap-anydpi-v26/
    ├── ic_launcher.xml (adaptive icon)
    └── ic_launcher_foreground.xml
```

### Android Splash Screens
```
android/app/src/main/res/
├── drawable/launch_background.xml
├── drawable/splash.png
├── drawable-v21/launch_background.xml
├── drawable-xxhdpi/splash.png
└── values-v31/styles.xml (Android 12+)
```

### iOS Icons
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-*.png (various sizes)
└── Contents.json
```

### iOS Splash
```
ios/Runner/Assets.xcassets/LaunchImage.imageset/
├── LaunchImage.png
├── LaunchImage@2x.png
├── LaunchImage@3x.png
└── Contents.json
```

### macOS Icons
```
macos/Runner/Assets.xcassets/AppIcon.appiconset/
├── app_icon_*.png (various sizes)
└── Contents.json
```

### Windows Icons
```
windows/runner/resources/app_icon.ico
```

---

## How to Update Logo/Icon

### 1. Prepare Your Logo
- **Format**: PNG with transparency
- **Recommended Size**: 1024x1024 pixels
- **File**: Replace `assets/logo.png`

### 2. Regenerate Icons
```bash
# From project root
dart run flutter_launcher_icons
```

### 3. Regenerate Splash Screens
```bash
# From project root
dart run flutter_native_splash:create
```

### 4. Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

---

## Configuration Details

### pubspec.yaml - Launcher Icons
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logo.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/logo.png"
  
  windows:
    generate: true
    image_path: "assets/logo.png"
    icon_size: 256
  
  macos:
    generate: true
    image_path: "assets/logo.png"
```

### pubspec.yaml - Native Splash
```yaml
flutter_native_splash:
  color: "#000000"
  image: assets/logo.png
  android: true
  ios: true
  web: false
  
  android_12:
    image: assets/logo.png
    color: "#000000"
    icon_background_color: "#000000"
  
  ios_content_mode: center
  android_gravity: center
  fullscreen: true
```

---

## Platform-Specific Notes

### Android
- **Adaptive Icons**: Supported on Android 8.0+ (API 26+)
- **Android 12+**: Special splash screen API with branded icon
- **Background**: Black (#000000)
- **Icon Shape**: System determines (circle, square, squircle, etc.)

### iOS
- **Multiple Sizes**: Generated automatically for all device sizes
- **Status Bar**: Hidden during splash (configured in Info.plist)
- **Content Mode**: Center (logo doesn't stretch)

### macOS
- **Icon Format**: ICNS (automatically generated)
- **Retina Support**: Yes (multiple resolutions included)
- **Dock Icon**: Uses the same app icon

### Windows
- **Icon Format**: ICO file
- **Size**: 256x256 pixels
- **Taskbar**: Uses the same icon

---

## Troubleshooting

### Logo Not Showing on Android
```bash
# Uninstall the app first
adb uninstall com.jbrc

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Wrong Icon After Update
```bash
# iOS/macOS
cd ios  # or cd macos
rm -rf Pods
pod install
cd ..

# Then rebuild
flutter clean
flutter run
```

### Splash Screen Not Updating
```bash
# Regenerate splash
dart run flutter_native_splash:create

# Clean build
flutter clean
flutter pub get

# Uninstall old app and reinstall
flutter run
```

---

## Color Customization

To change the splash screen background color:

1. Edit `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#YOUR_HEX_COLOR"  # e.g., "#FFFFFF" for white
  # ... rest of config
```

2. Regenerate:
```bash
dart run flutter_native_splash:create
```

---

## Best Practices

✅ **DO:**
- Use PNG format with transparency
- Use high resolution (1024x1024 minimum)
- Keep the logo centered and simple
- Test on multiple devices
- Use consistent branding

❌ **DON'T:**
- Use JPEG (no transparency)
- Use low resolution images
- Add text that might be cut off
- Use complex gradients that might not render well
- Forget to test on different screen sizes

---

## Files Modified

The following configuration files were updated:
- ✅ `pubspec.yaml` - Icon and splash config
- ✅ `android/app/src/main/AndroidManifest.xml` - App label
- ✅ `ios/Runner/Info.plist` - App name and permissions
- ✅ `macos/Runner/Info.plist` - App name and permissions
- ✅ `macos/Runner/DebugProfile.entitlements` - Permissions
- ✅ `macos/Runner/Release.entitlements` - Permissions
- ✅ `windows/runner/main.cpp` - Window title

---

## Quick Commands Reference

```bash
# Regenerate everything
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter clean
flutter pub get

# Build for specific platform
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ipa --release        # iOS
flutter build macos --release      # macOS
flutter build windows --release    # Windows

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d macos
flutter run -d windows
```

---

**Status**: All platforms configured ✅  
**Last Updated**: October 11, 2025  
**Configuration**: Automatic via flutter_launcher_icons & flutter_native_splash  
