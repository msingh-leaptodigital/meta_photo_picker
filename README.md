# meta_photo_picker

A modern, privacy-focused Flutter plugin for picking photos from the device gallery with detailed metadata.

## 🌟 Introduction

`meta_photo_picker` provides a unified API for photo selection across iOS and Android platforms:

- **iOS**: Uses Apple's privacy-preserving PHPicker (iOS 14+) - **no permission required!**
- **Android**: Uses the popular [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker) for a native experience

The plugin returns detailed metadata for each selected photo including file information, dimensions, and image data, making it perfect for apps that need more than just image selection.

## ✨ Features

### Core Features
- 🖼️ **Pick single or multiple photos** from the device gallery
- 🔒 **Privacy-first on iOS** - PHPicker doesn't require photo library permission
- 📊 **Rich metadata** for each selected photo
- 🎨 **Native UI** on both platforms
- ⚡ **Fast and efficient** - optimized for performance
- 🔧 **Highly configurable** picker options

### Metadata Included
- File name, size (bytes and formatted), and type (JPEG, PNG, HEIC, etc.)
- Image dimensions (width, height) and aspect ratio
- Creation date (ISO 8601 format)
- Asset identifier (for photo library reference)
- Image data (raw bytes for display)
- Image orientation and scale factor

### Configuration Options
- Selection limit (single, multiple, or unlimited)
- Media type filter (images, videos, live photos, or all)
- Asset representation mode (automatic, current, compatible)
- Compression quality (0.0 - 1.0, default 1.0 = no compression)

### Additional Features
- 📱 **Check photo access status** - Know if user has granted full, limited, or no access
- 🔄 **Direct selection on Android** - Tap to select, no preview needed
- 🎯 **Type-safe models** - Well-defined Dart models for all data
- 📝 **Comprehensive documentation** - Clear examples and API docs

## 🆚 Platform Differences

| Feature | iOS (PHPicker) | Android (wechat_assets_picker) |
|---------|----------------|--------------------------------|
| **Permission Required** | ❌ No | ✅ Yes |
| **Privacy** | ✅ Privacy-preserving | ⚠️ Requires storage access |
| **Limited Access** | ✅ Supported (iOS 14+) | ✅ Supported (Android 14+/API 34+) |
| **Permission State Updates** | ✅ Immediate | ⚠️ Requires app restart |
| **UI** | Native iOS picker | Material Design picker |
| **Selection Speed** | Fast | Fast (optimized) |
| **Context Required** | ❌ No | ✅ Yes |

## 📱 Platform Support

| Platform | Minimum Version | Implementation |
|----------|----------------|----------------|
| iOS      | iOS 14.0+ | PHPicker (privacy-preserving) |
| Android  | API 21+ (Android 5.0+) | wechat_assets_picker |

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  meta_photo_picker: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## ⚙️ Platform Setup

### iOS Setup

**1. Add permission to `ios/Runner/Info.plist`:**

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select and display photos.</string>
```

**Note:** Even though PHPicker doesn't require permission for basic photo selection, this description is still needed in Info.plist for App Store submission.

**2. Minimum iOS version:**

Ensure your `ios/Podfile` has iOS 14.0 or higher:

```ruby
platform :ios, '14.0'
```

### Android Setup

The plugin uses [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker) for Android, which requires proper permission configuration.

**1. Add permissions to `android/app/src/main/AndroidManifest.xml`:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- For Android 12 and below (API 32-) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    
    <!-- For Android 13+ (API 33+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    
    <!-- Optional: For accessing photo location metadata -->
    <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />
    
    <application ...>
        ...
    </application>
</manifest>
```

**2. Update `android/app/build.gradle`:**

```gradle
android {
    compileSdkVersion 34  // or higher
    
    defaultConfig {
        applicationId "com.example.yourapp"
        minSdkVersion 21      // Minimum API 21
        targetSdkVersion 34   // Target latest
    }
}
```

**3. Update `android/gradle/wrapper/gradle-wrapper.properties`:**

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
```

**4. Update `android/build.gradle`:**

```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.1.0'  // or higher
}
```

**Permission Handling:**
- The plugin automatically requests the appropriate permission based on Android version
- Android 13+ (API 33+): Uses `READ_MEDIA_IMAGES`
- Android 12 and below: Uses `READ_EXTERNAL_STORAGE`
- Permission is requested when `pickPhotos()` is called

## 🚀 Usage

### Quick Start

```dart
import 'package:meta_photo_picker/meta_photo_picker.dart';

final picker = MetaPhotoPicker();

// Pick a single photo
final photo = await picker.pickSinglePhoto(context: context);

// Pick multiple photos
final photos = await picker.pickPhotos(context: context);
```

### Basic Example - Pick Single Photo

```dart
import 'package:flutter/material.dart';
import 'package:meta_photo_picker/meta_photo_picker.dart';

class MyWidget extends StatelessWidget {
  final picker = MetaPhotoPicker();

  Future<void> pickPhoto(BuildContext context) async {
    // Pick a single photo (context required for Android)
    final photo = await picker.pickSinglePhoto(context: context);

    if (photo != null) {
      print('✅ Selected: ${photo.fileName}');
      print('📦 Size: ${photo.fileSize}');
      print('📐 Dimensions: ${photo.dimensions.width}x${photo.dimensions.height}');
      print('🎨 Type: ${photo.fileType}');
      
      // Display the image
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Image.memory(photo.imageData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => pickPhoto(context),
      child: Text('Pick Photo'),
    );
  }
}
```

### Pick Multiple Photos with Configuration

```dart
import 'package:meta_photo_picker/meta_photo_picker.dart';

final picker = MetaPhotoPicker();

// Configure picker options
final config = PickerConfig(
  selectionLimit: 5,           // Pick up to 5 photos (0 = unlimited)
  filter: PickerFilter.images, // Only show images
  preferredAssetRepresentationMode: AssetRepresentationMode.current,
  compressionQuality: 1.0,     // No compression (original quality)
);

// Pick multiple photos
final photos = await picker.pickPhotos(
  config: config,
  context: context, // Required for Android
);

if (photos != null && photos.isNotEmpty) {
  print('📸 Picked ${photos.length} photos');
  
  for (var photo in photos) {
    print('---');
    print('📄 File: ${photo.fileName}');
    print('📦 Size: ${photo.fileSize}');
    print('🎨 Type: ${photo.fileType}');
    print('📐 Dimensions: ${photo.dimensions.width}x${photo.dimensions.height}');
    print('📅 Created: ${photo.creationDate}');
    print('🆔 ID: ${photo.id}');
  }
}
```

### Display Selected Photos

```dart
import 'package:flutter/material.dart';
import 'package:meta_photo_picker/meta_photo_picker.dart';

class PhotoGallery extends StatefulWidget {
  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final picker = MetaPhotoPicker();
  List<PhotoInfo> selectedPhotos = [];

  Future<void> pickPhotos() async {
    final photos = await picker.pickPhotos(
      context: context,
      config: PickerConfig(selectionLimit: 0), // Unlimited
    );

    if (photos != null) {
      setState(() {
        selectedPhotos.addAll(photos);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Gallery')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: selectedPhotos.length,
        itemBuilder: (context, index) {
          final photo = selectedPhotos[index];
          return Image.memory(
            photo.imageData,
            fit: BoxFit.cover,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickPhotos,
        child: Icon(Icons.add_photo_alternate),
      ),
    );
  }
}
```

### Check Photo Access Status

Check if the user has granted photo library access (useful for showing UI hints):

```dart
final picker = MetaPhotoPicker();

// Check access status
final status = await picker.checkPhotoAccessStatus();

switch (status) {
  case PhotoAccessStatus.fullAccess:
    print('✅ Full access granted');
    break;
  case PhotoAccessStatus.limitedAccess:
    print('⚠️ Limited access (iOS only - user selected specific photos)');
    break;
  case PhotoAccessStatus.noAccess:
    print('❌ No access - need to request permission');
    break;
}

// Use in your UI
if (status == PhotoAccessStatus.noAccess) {
  // Show a message to the user
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Permission Needed'),
      content: Text('Please grant photo access to select images.'),
    ),
  );
}
```

**Note:** 
- On iOS with PHPicker, this will always return `fullAccess` or `limitedAccess` since no permission is required
- On Android, this checks the actual storage permission status
- `limitedAccess` is only available on iOS 14+ when user selects specific photos

**⚠️ Android Important:** On Android 14+ (API 34+), the permission state is cached by the system. If a user changes permissions in system settings (from limited to full access or vice versa), the app must be completely terminated and restarted for the new permission state to be reflected. This is Android system behavior - the permission state is stored in the app's process memory and only updates on app restart.

## 📖 API Reference

### Configuration Options

#### PickerConfig

```dart
PickerConfig({
  int selectionLimit = 1,                    // Number of photos to select (0 = unlimited)
  PickerFilter filter = PickerFilter.images, // Media type filter
  AssetRepresentationMode preferredAssetRepresentationMode = AssetRepresentationMode.current,
  double compressionQuality = 1.0,           // JPEG compression (0.0 - 1.0)
})
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selectionLimit` | `int` | `1` | Maximum number of photos to select. Set to `0` for unlimited. |
| `filter` | `PickerFilter` | `images` | Filter media types shown in picker. |
| `preferredAssetRepresentationMode` | `AssetRepresentationMode` | `current` | How assets should be represented (iOS only). |
| `compressionQuality` | `double` | `1.0` | JPEG compression quality (1.0 = no compression). |

#### PickerFilter Options

| Value | Description | Platform Support |
|-------|-------------|------------------|
| `PickerFilter.images` | Show only images (JPEG, PNG, HEIC, etc.) | iOS & Android |
| `PickerFilter.videos` | Show only videos | iOS & Android |
| `PickerFilter.livePhotos` | Show only live photos | iOS only (falls back to images on Android) |
| `PickerFilter.any` | Show all media types | iOS & Android |

#### AssetRepresentationMode Options

| Value | Description | Use Case |
|-------|-------------|----------|
| `automatic` | System decides best format | Let iOS choose optimal format |
| `current` | Use current format (e.g., HEIC) | Preserve original format |
| `compatible` | Convert to compatible format (JPEG) | Ensure compatibility |

**Note:** `AssetRepresentationMode` only affects iOS. Android always returns the original format.

### PhotoInfo Model

Each selected photo returns a `PhotoInfo` object with comprehensive metadata:

```dart
class PhotoInfo {
  final String id;                    // Unique identifier
  final String fileName;              // File name (e.g., "IMG_1234.jpg")
  final int fileSizeBytes;           // Size in bytes (e.g., 2547891)
  final String fileSize;             // Formatted size (e.g., "2.43 MB")
  final PhotoDimensions dimensions;  // Width and height
  final String? creationDate;        // ISO 8601 format (e.g., "2024-01-15T10:30:00Z")
  final String fileType;             // File type: "JPEG", "PNG", "HEIC", "GIF", "WEBP"
  final String? assetIdentifier;     // Photos library asset ID (platform-specific)
  final Uint8List imageData;         // Raw image bytes for display
  final double scale;                // Image scale factor (typically 1.0)
  final ImageOrientation orientation; // Image orientation (up, down, left, right, etc.)
  
  // Computed properties
  double get aspectRatio;            // Width / height ratio
}
```

**PhotoDimensions:**

```dart
class PhotoDimensions {
  final int width;   // Image width in pixels
  final int height;  // Image height in pixels
}
```

**ImageOrientation:**

```dart
enum ImageOrientation {
  up,           // Normal orientation
  down,         // Rotated 180°
  left,         // Rotated 90° counter-clockwise
  right,        // Rotated 90° clockwise
  upMirrored,   // Flipped horizontally
  downMirrored, // Flipped horizontally and rotated 180°
  leftMirrored, // Flipped horizontally and rotated 90° counter-clockwise
  rightMirrored,// Flipped horizontally and rotated 90° clockwise
}
```

**Example Usage:**

```dart
final photo = await picker.pickSinglePhoto(context: context);

if (photo != null) {
  // File information
  print('File: ${photo.fileName}');           // "IMG_1234.HEIC"
  print('Size: ${photo.fileSize}');           // "2.43 MB"
  print('Type: ${photo.fileType}');           // "HEIC"
  
  // Image properties
  print('Width: ${photo.dimensions.width}');   // 4032
  print('Height: ${photo.dimensions.height}'); // 3024
  print('Aspect: ${photo.aspectRatio}');       // 1.333
  print('Orientation: ${photo.orientation}');  // ImageOrientation.up
  
  // Display the image
  Image.memory(photo.imageData);
  
  // Save to file
  final file = File('path/to/save/${photo.fileName}');
  await file.writeAsBytes(photo.imageData);
}
```

## 🎯 Complete Example App

See the [example](example/) directory for a complete working app that demonstrates:

- ✅ Picking single and multiple photos
- ✅ Displaying selected photos in a grid
- ✅ Showing detailed photo information (size, dimensions, type, etc.)
- ✅ Deleting individual photos
- ✅ Clearing all photos
- ✅ Permission status checking
- ✅ Modern Material Design UI
- ✅ Error handling

**Run the example:**

```bash
cd example
flutter run
```

## 🛡️ Error Handling

### Basic Error Handling

```dart
try {
  final photos = await picker.pickPhotos(context: context);
  
  if (photos != null && photos.isNotEmpty) {
    print('✅ Selected ${photos.length} photos');
  } else {
    print('ℹ️ User cancelled or no photos selected');
  }
} on PlatformException catch (e) {
  print('❌ Platform error: ${e.code} - ${e.message}');
} catch (e) {
  print('❌ Unexpected error: $e');
}
```

### Comprehensive Error Handling

```dart
Future<void> pickPhotosWithErrorHandling(BuildContext context) async {
  try {
    final picker = MetaPhotoPicker();
    
    // Check access status first (optional)
    final status = await picker.checkPhotoAccessStatus();
    if (status == PhotoAccessStatus.noAccess) {
      // Show permission explanation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Needed'),
          content: Text('Please grant photo access to select images.'),
        ),
      );
      return;
    }
    
    // Pick photos
    final photos = await picker.pickPhotos(
      context: context,
      config: PickerConfig(selectionLimit: 10),
    );
    
    if (photos != null && photos.isNotEmpty) {
      // Success!
      print('✅ Selected ${photos.length} photos');
      // Process photos...
    } else {
      // User cancelled
      print('ℹ️ User cancelled selection');
    }
    
  } on PlatformException catch (e) {
    // Platform-specific errors
    String message;
    switch (e.code) {
      case 'PERMISSION_DENIED':
        message = 'Permission denied. Please grant photo access.';
        break;
      case 'UNSUPPORTED_VERSION':
        message = 'This feature requires iOS 14 or later.';
        break;
      default:
        message = 'Error: ${e.message ?? "Unknown error"}';
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    
  } catch (e) {
    // Unexpected errors
    print('❌ Unexpected error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }
}
```

## ⚠️ Important Notes

### iOS Specific

- ✅ **No permission required** - PHPicker is privacy-preserving
- ✅ **Works immediately** - No permission dialog for basic photo selection
- ⚠️ **iOS 14+ required** - PHPicker is not available on older iOS versions
- ℹ️ **Limited access** - iOS 14+ users can grant access to selected photos only
- ℹ️ **Creation date** - Uses current date as fallback (no PHAsset access needed)

### Android Specific

- ⚠️ **Permission required** - Must grant storage/media permission
- ⚠️ **Context required** - BuildContext must be passed to `pickPhotos()`
- ✅ **Auto-permission** - Plugin automatically requests appropriate permission
- ✅ **Version-aware** - Uses `READ_MEDIA_IMAGES` on Android 13+, `READ_EXTERNAL_STORAGE` on older versions
- ✅ **Direct selection** - Tap to select, no preview needed

#### ⚠️ Android Limited Permission Behavior

**Important:** On Android 14+ (API 34+), when a user grants "Limited Access" (selects specific photos), the permission state is **cached by the system** and will not update until the app session terminates.

**What this means:**
- If a user initially grants limited access and selects specific photos
- Then goes to system settings and grants full access
- The app will **still see limited access** until the app is completely closed and reopened
- This is Android system behavior, not a plugin limitation

**Workaround:**
```dart
final picker = MetaPhotoPicker();

// Check permission status
final status = await picker.checkPhotoAccessStatus();

if (status == PhotoAccessStatus.limitedAccess) {
  // Show dialog informing user they need to restart the app
  // after changing permissions in system settings
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Limited Access'),
      content: Text(
        'You have granted limited access. If you change permissions '
        'in system settings, please close and reopen the app for '
        'changes to take effect.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

**Technical Details:**
- The permission state is retrieved from `Permission.photos.status` on Android
- Android caches this state in the app's process memory
- Only terminating the app process (force stop or app restart) clears this cache
- This behavior is documented in Android's [photo picker documentation](https://developer.android.com/training/data-storage/shared/photopicker)

**Best Practice:**
Inform users that if they change photo permissions in system settings, they should:
1. Completely close the app (swipe away from recent apps)
2. Reopen the app
3. The new permission state will then be reflected

### Memory Considerations

- ⚠️ **Image data in memory** - Each `PhotoInfo` contains full image bytes
- 💡 **Large images** - Consider memory usage when selecting many large photos
- 💡 **Optimization** - Process and save images to disk, then clear from memory
- 💡 **Compression** - Use `compressionQuality` parameter to reduce memory usage

### Platform Differences

| Feature | iOS | Android |
|---------|-----|---------|
| Permission dialog | ❌ Not shown | ✅ Shown on first use |
| Limited access | ✅ Supported | ✅ Supported (API 34+) |
| Permission state refresh | ✅ Immediate | ⚠️ Requires app restart |
| Context required | ❌ No | ✅ Yes |
| Live Photos | ✅ Supported | ❌ Falls back to images |
| Creation date | ⚠️ Fallback to current | ✅ Actual date |

## 📝 Best Practices

### 1. Always Check Context Availability

```dart
// ✅ Good
if (context.mounted) {
  final photos = await picker.pickPhotos(context: context);
}

// ❌ Bad
final photos = await picker.pickPhotos(context: context);
// Context might be unmounted
```

### 2. Handle Null Results

```dart
// ✅ Good
final photos = await picker.pickPhotos(context: context);
if (photos != null && photos.isNotEmpty) {
  // Process photos
}

// ❌ Bad
final photos = await picker.pickPhotos(context: context);
for (var photo in photos) { // Might throw if null
  // ...
}
```

### 3. Manage Memory for Large Selections

```dart
// ✅ Good - Process and save immediately
final photos = await picker.pickPhotos(context: context);
if (photos != null) {
  for (var photo in photos) {
    // Save to disk
    final file = File('path/${photo.fileName}');
    await file.writeAsBytes(photo.imageData);
  }
  // Clear from memory
  photos.clear();
}

// ❌ Bad - Keep all in memory
final allPhotos = <PhotoInfo>[];
final photos = await picker.pickPhotos(context: context);
if (photos != null) {
  allPhotos.addAll(photos); // Memory grows indefinitely
}
```

### 4. Provide User Feedback

```dart
// ✅ Good - Show loading and feedback
setState(() => isLoading = true);

final photos = await picker.pickPhotos(context: context);

setState(() => isLoading = false);

if (photos != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Added ${photos.length} photo(s)')),
  );
}
```

## ❓ FAQ

**Q: Do I need to request permission on iOS?**
A: No! PHPicker is privacy-preserving and doesn't require photo library permission. The picker is handled by the system.

**Q: Why do I need to pass BuildContext?**
A: BuildContext is required for Android to show the picker dialog. iOS doesn't need it but we keep the API consistent.

**Q: Can I get the actual creation date on iOS?**
A: Not without requesting photo library permission. To keep the plugin permission-free on iOS, we use the current date as a fallback.

**Q: What's the difference between `fullAccess` and `limitedAccess`?**
A: On iOS 14+, users can choose to give apps access to all photos (`fullAccess`) or only selected photos (`limitedAccess`). Both work with PHPicker.

**Q: How do I handle large images?**
A: Consider using the `compressionQuality` parameter to reduce file size, or process and save images to disk immediately after selection.

**Q: Does this work with videos?**
A: Yes! Use `PickerFilter.videos` or `PickerFilter.any` to include videos. The plugin returns video data the same way as images.

**Q: Can I customize the picker UI?**
A: No. Both PHPicker (iOS) and wechat_assets_picker (Android) use system/native UI for consistency and security.

**Q: Why doesn't the permission status update after I change it in Android settings?**
A: On Android 14+ (API 34+), the permission state is cached by the Android system in the app's process memory. After changing permissions in system settings, you must completely close and reopen the app for the new permission state to be retrieved. This is standard Android behavior, not a plugin limitation. The app needs to be terminated (force stopped or swiped away from recent apps) and relaunched to see the updated permission state.

## 🔧 Troubleshooting

### iOS Issues

**"PHPicker requires iOS 14 or later"**
- Ensure your `ios/Podfile` has `platform :ios, '14.0'` or higher
- Run `cd ios && pod install`

**Images not loading**
- Check that `NSPhotoLibraryUsageDescription` is in `Info.plist`
- Verify the app has been rebuilt after adding the permission

### Android Issues

**"Permission denied"**
- Ensure permissions are in `AndroidManifest.xml`
- Check that `compileSdkVersion` is 33 or higher
- Verify Gradle version is 8.0 or higher

**"Context is required for Android picker"**
- Always pass `context` parameter: `picker.pickPhotos(context: context)`

**Gradle build errors**
- Update Gradle to 8.0+
- Update Android Gradle Plugin to 8.1.0+
- Ensure `minSdkVersion` is 21 or higher

**Permission status not updating after changing in settings**
- This is expected Android behavior on Android 14+ (API 34+)
- The permission state is cached in the app's process memory
- Solution: Completely close the app (force stop or swipe from recent apps) and reopen it
- The new permission state will be retrieved when the app restarts
- This affects the `checkPhotoAccessStatus()` method
- The picker itself will still work, but the status check will show the cached state

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/meta_photo_picker.git

# Install dependencies
cd meta_photo_picker
flutter pub get

# Run example app
cd example
flutter run

# Run tests
cd ..
flutter test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Apple's [PHPicker](https://developer.apple.com/documentation/photokit/phpicker) framework for iOS
- Uses [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker) for Android
- Uses [permission_handler](https://pub.dev/packages/permission_handler) for permission management

## 📚 Additional Resources

- [PHPicker Documentation](https://developer.apple.com/documentation/photokit/phpicker)
- [Android Photo Picker](https://developer.android.com/training/data-storage/shared/photopicker)
- [Flutter Plugin Development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)

---

Made with ❤️ for the Flutter community

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Based on Apple's PHPicker framework for iOS.
