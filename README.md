# meta_photo_picker

A Flutter plugin for picking images using PHPicker on iOS with detailed metadata information.

## Features

- 🖼️ Pick single or multiple images from the photo library
- 📊 Get detailed metadata for each selected photo:
  - File name, size, and type
  - Image dimensions and aspect ratio
  - Creation date
  - Asset identifier
  - Image orientation and scale
- ⚙️ Configurable picker options:
  - Selection limit (single, multiple, or unlimited)
  - Filter by media type (images, videos, live photos)
  - Asset representation mode
  - JPEG compression quality
- 🎨 Modern PHPicker UI (iOS 14+)
- 📱 Full support for HEIC, JPEG, PNG, and other image formats

## Platform Support

| Platform | Supported | Implementation |
|----------|-----------|----------------|
| iOS      | ✅ (iOS 14+) | PHPicker |
| Android  | ✅ (API 21+) | [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker) |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  meta_photo_picker: ^0.0.1
```

## Platform Setup

### iOS

Add the following permission to your `Info.plist` file:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select and display photos.</string>
```

### Android

The plugin uses [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker) for Android.

**1. Add permissions to your `android/app/src/main/AndroidManifest.xml`:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions for photo access -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
                     android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />
    
    <application ...>
        ...
    </application>
</manifest>
```

**2. Update your `android/app/build.gradle`:**

```gradle
android {
    compileSdkVersion 33  // or higher
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33  // or higher
    }
}
```

**Note**: 
- `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO` are required for Android 13+ (API 33+)
- `READ_EXTERNAL_STORAGE` is for Android 12 and below (API 32-)

## Usage

### Basic Example - Pick Single Photo

```dart
import 'package:meta_photo_picker/meta_photo_picker.dart';
import 'dart:typed_data';

final picker = MetaPhotoPicker();

// Pick a single photo (context required for Android)
final photo = await picker.pickSinglePhoto(context: context);

if (photo != null) {
  print('Selected: ${photo.fileName}');
  print('Size: ${photo.fileSize}');
  print('Dimensions: ${photo.dimensions}');
  
  // Display the image
  Image.memory(Uint8List.fromList(photo.imageData));
}
```

### Pick Multiple Photos

```dart
import 'package:meta_photo_picker/meta_photo_picker.dart';

final picker = MetaPhotoPicker();

// Configure picker options
final config = PickerConfig(
  selectionLimit: 5, // 0 for unlimited
  filter: PickerFilter.images,
  preferredAssetRepresentationMode: AssetRepresentationMode.current,
  compressionQuality: 1.0, // 1.0 = no compression (default)
);

// Pick multiple photos (context required for Android)
final photos = await picker.pickPhotos(
  config: config,
  context: context,
);

if (photos != null) {
  for (var photo in photos) {
    print('File: ${photo.fileName}');
    print('Size: ${photo.fileSize}');
    print('Type: ${photo.fileType}');
    print('Dimensions: ${photo.dimensions}');
    print('Created: ${photo.creationDate}');
    print('---');
  }
}
```

### Configuration Options

#### PickerConfig

```dart
PickerConfig(
  selectionLimit: 1,           // Number of photos (0 = unlimited)
  filter: PickerFilter.images, // Media type filter
  preferredAssetRepresentationMode: AssetRepresentationMode.current,
  compressionQuality: 1.0,     // JPEG quality (0.0 - 1.0, default 1.0 = no compression)
)
```

#### PickerFilter Options

- `PickerFilter.images` - Show only images
- `PickerFilter.videos` - Show only videos
- `PickerFilter.livePhotos` - Show only live photos
- `PickerFilter.any` - Show all media types

#### AssetRepresentationMode Options

- `AssetRepresentationMode.automatic` - System decides best format
- `AssetRepresentationMode.current` - Use current format (e.g., HEIC)
- `AssetRepresentationMode.compatible` - Convert to compatible format (e.g., JPEG)

### PhotoInfo Model

Each selected photo returns a `PhotoInfo` object with the following properties:

```dart
class PhotoInfo {
  final String id;                    // Unique identifier
  final String fileName;              // File name
  final int fileSizeBytes;           // Size in bytes
  final String fileSize;             // Formatted size (e.g., "2.5 MB")
  final PhotoDimensions dimensions;  // Width and height
  final String? creationDate;        // ISO 8601 format
  final String fileType;             // "JPEG", "PNG", "HEIC", etc.
  final String? assetIdentifier;     // Photos library asset ID
  final List<int> imageData;         // Image bytes
  final double scale;                // Image scale factor
  final ImageOrientation orientation; // Image orientation
  
  double get aspectRatio;            // Calculated aspect ratio
}
```

### Complete Example

See the [example](example/) directory for a complete working app that demonstrates:
- Picking single and multiple photos
- Displaying selected photos in a list
- Showing detailed photo information
- Deleting selected photos
- Modern Material Design UI

## Error Handling

```dart
try {
  final photos = await picker.pickPhotos();
  // Handle photos
} on PlatformException catch (e) {
  print('Error: ${e.message}');
}
```

## Limitations

- **iOS**: Requires iOS 14 or later for PHPicker
- **Android**: Uses wechat_assets_picker, requires API 21+
- **Context Required**: BuildContext must be passed on Android
- Image data is loaded into memory (consider memory usage for large images)
- Live Photos filter only works on iOS (falls back to images on Android)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Based on Apple's PHPicker framework for iOS.
