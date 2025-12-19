## 0.0.2

* **Bug Fixes:**
  - Fixed Android picker showing "1/9999" count on confirm button - now shows reasonable default of 150 for unlimited selection
  - Disabled intrusive limited permission warning dialog on Android - picker now works smoothly without showing system warning overlay
* **Android Permission Improvements:**
  - Improved permission state handling for Android 14+ (API 34+)
  - Fixed `checkPhotoAccessStatus()` to use `Permission.photos.status` for more reliable state checking
  - Added `limitedPermissionOverlayPredicate` to prevent unwanted permission dialogs during photo selection
* **Documentation Updates:**
  - Added comprehensive documentation for Android limited permission behavior
  - Documented Android permission state caching and app restart requirement
  - Updated platform comparison tables to reflect Android 14+ limited access support
  - Added FAQ entry explaining permission state caching behavior
  - Added troubleshooting section for permission status not updating
  - Included code examples for handling limited permission scenarios

## 0.0.1

* Initial release of meta_photo_picker
* **iOS implementation using PHPicker (iOS 14+)**
  - Privacy-preserving - no permission required
  - Shows all photos to user regardless of permission status
  - Native system picker UI
* **Android implementation using wechat_assets_picker (API 21+)**
  - Automatic permission handling
  - Version-aware permission requests (READ_MEDIA_IMAGES for Android 13+)
  - Direct selection without preview
* **Cross-platform features:**
  - Pick single or multiple images from photo library
  - Comprehensive photo metadata including:
    - File name, size (bytes and formatted), and type
    - Image dimensions (width, height) and aspect ratio
    - Creation date (ISO 8601 format)
    - Asset identifier
    - Image orientation and scale
    - Raw image data (Uint8List)
  - Configurable picker options:
    - Selection limit (single, multiple, unlimited)
    - Media type filters (images, videos, live photos)
    - Asset representation modes (iOS)
    - JPEG compression quality (default: no compression)
  - Permission status checking (checkPhotoAccessStatus, requestPermission, isPermissionGranted)
  - Type-safe Dart models (PhotoInfo, PickerConfig, PhotoDimensions, ImageOrientation)
* Complete example app with modern Material Design UI
* Comprehensive documentation and README
* Full test coverage
