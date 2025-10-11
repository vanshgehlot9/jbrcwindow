# Quick Start Guide

## 🚀 Running Your Updated App

### 1. Install Dependencies (Already Done ✅)
```bash
flutter pub get
```

### 2. Run on Your Device
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Desktop
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

---

## 🎯 New Features

### ✅ Download/Export Functionality
**How it works:**
- When your web app triggers a download (e.g., exporting a bilty as PDF)
- The app will automatically intercept the download
- On mobile: saves to Downloads folder
- On desktop: shows "Save As" dialog
- File opens automatically after download

**No changes needed in your web app!** The WebView will automatically handle all downloads.

### 🚚 Animated Truck Splash Screen
**What you'll see:**
- Beautiful animated truck moving across the screen
- "JBRC" branding with glow effect
- "Transport Management" subtitle
- Smooth 2-second animation before app loads

---

## 🎨 Customizing the Truck Animation

### Change Animation Speed
In `lib/main.dart`, find:
```dart
_controller = AnimationController(
  duration: const Duration(milliseconds: 2000), // Change this value
  vsync: this,
);
```

### Change Truck Color
In `lib/main.dart`, find `TruckPainter` and change:
```dart
final paint = Paint()
  ..color = Colors.pinkAccent  // Change to any color
  ..style = PaintingStyle.fill;
```

### Change Text/Branding
Find this section:
```dart
Text(
  'JBRC',  // Change company name
  style: TextStyle(
    color: Colors.pinkAccent,
    fontSize: 48,  // Adjust size
    fontWeight: FontWeight.bold,
    letterSpacing: 8,
  ),
),
```

---

## 🐛 Troubleshooting

### Downloads Not Working on Android
1. Make sure storage permissions are granted
2. Check if the file is in Downloads folder
3. Try downloading a different file type

### Splash Screen Not Showing
1. Clear app cache: `flutter clean`
2. Rebuild: `flutter run`

### Animation Choppy
1. Run in release mode: `flutter run --release`
2. Animations are always smoother in release mode

---

## 📱 Platform-Specific Testing

### Android
```bash
flutter run -d android
```
- Test download to Downloads folder
- Verify file opens automatically

### iOS
```bash
flutter run -d ios
```
- Test download to Documents
- Access files through Files app

### Desktop
```bash
flutter run -d macos  # or windows/linux
```
- Test "Save As" dialog
- Verify file saves to chosen location

---

## 🎉 That's It!

Your app now has:
- ✅ Full download/export support across all platforms
- ✅ Beautiful animated truck splash screen
- ✅ Automatic file opening after download
- ✅ Native platform integration

**Enjoy your enhanced transport management app!**
