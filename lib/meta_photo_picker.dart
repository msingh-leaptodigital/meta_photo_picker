import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'meta_photo_picker_platform_interface.dart';
import 'models/photo_info.dart';
import 'models/picker_config.dart';

export 'models/photo_info.dart';
export 'models/picker_config.dart';
export 'package:permission_handler/permission_handler.dart' show PermissionStatus;

/// Photo access status enum
///
/// **CRITICAL: This refers to PHAsset API permission, NOT PHPicker access!**
///
/// On iOS:
/// - PHPicker (used by this plugin) does NOT require photo library permission
/// - PHPicker always shows ALL photos, regardless of this status
/// - This enum reflects PHAsset API access (for direct photo library access)
/// - `limitedAccess` means only selected photos are accessible via PHAsset API
/// - **PHPicker is NOT affected by this limitation**
///
/// On Android:
/// - Permission IS required for the picker to work
/// - This enum accurately reflects picker access
enum PhotoAccessStatus {
  /// Full access to photo library
  ///
  /// - **iOS**: Full PHAsset API access (PHPicker always works regardless)
  /// - **Android**: Full picker access granted
  fullAccess,

  /// Limited access (iOS 14+ only - user selected specific photos)
  ///
  /// - **iOS**: Limited PHAsset API access, but **PHPicker still shows ALL photos**
  /// - **Android**: May be returned in rare cases, treated as full access
  ///
  /// **Important**: On iOS, this does NOT limit PHPicker. The user will still
  /// see and can select from ALL photos when using this plugin.
  limitedAccess,

  /// No access granted
  ///
  /// - **iOS**: No PHAsset API access, but **PHPicker still works and shows ALL photos**
  /// - **Android**: No picker access - permission required
  noAccess,
}

/// Main class for the Meta Photo Picker plugin
/// 
/// This plugin provides access to:
/// - PHPicker on iOS for selecting photos with detailed metadata
/// - WeChat Assets Picker on Android for a similar experience
class MetaPhotoPicker {
  /// Gets the platform version
  Future<String?> getPlatformVersion() {
    return MetaPhotoPickerPlatform.instance.getPlatformVersion();
  }

  /// Opens the photo picker and returns a list of selected photos with detailed information
  /// 
  /// [config] - Configuration options for the picker (optional)
  /// [context] - BuildContext required for Android picker (optional, but required on Android)
  /// 
  /// Returns a list of [PhotoInfo] objects containing detailed information about
  /// each selected photo, or null if the user cancels the picker.
  /// 
  /// Example:
  /// ```dart
  /// final picker = MetaPhotoPicker();
  /// final config = PickerConfig(
  ///   selectionLimit: 5,
  ///   filter: PickerFilter.images,
  /// );
  /// final photos = await picker.pickPhotos(
  ///   config: config,
  ///   context: context, // Required on Android
  /// );
  /// if (photos != null) {
  ///   for (var photo in photos) {
  ///     print('Selected: ${photo.fileName} (${photo.fileSize})');
  ///   }
  /// }
  /// ```
  Future<List<PhotoInfo>?> pickPhotos({
    PickerConfig? config,
    BuildContext? context,
  }) async {
    final pickerConfig = config ?? PickerConfig();

    if (Platform.isAndroid) {
      return _pickPhotosAndroid(pickerConfig, context);
    } else if (Platform.isIOS) {
      return MetaPhotoPickerPlatform.instance.pickPhotos(config: pickerConfig);
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Opens the photo picker for selecting a single photo
  /// 
  /// This is a convenience method that sets selectionLimit to 1 and returns
  /// a single [PhotoInfo] object instead of a list.
  /// 
  /// [context] - BuildContext required for Android picker (optional, but required on Android)
  /// 
  /// Returns a [PhotoInfo] object with detailed information about the selected photo,
  /// or null if the user cancels the picker.
  /// 
  /// Example:
  /// ```dart
  /// final picker = MetaPhotoPicker();
  /// final photo = await picker.pickSinglePhoto(context: context);
  /// if (photo != null) {
  ///   print('Selected: ${photo.fileName}');
  /// }
  /// ```
  Future<PhotoInfo?> pickSinglePhoto({
    PickerConfig? config,
    BuildContext? context,
  }) async {
    final modifiedConfig = (config ?? PickerConfig()).copyWith(selectionLimit: 1);
    final photos = await pickPhotos(config: modifiedConfig, context: context);
    return photos?.isNotEmpty == true ? photos!.first : null;
  }

  /// Android implementation using wechat_assets_picker
  Future<List<PhotoInfo>?> _pickPhotosAndroid(
    PickerConfig config,
    BuildContext? context,
  ) async {
    if (context == null) {
      throw ArgumentError('BuildContext is required for Android picker');
    }

    // Request permission for Android only
    // Note: iOS PHPicker doesn't require permission
    debugPrint('🔐 Checking photo permission for Android...');

    // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
    // For Android 12 and below, use READ_EXTERNAL_STORAGE
    final androidVersion = await _getAndroidVersion();
    final permission = androidVersion >= 33 ? Permission.photos : Permission.storage;
    
    debugPrint('📱 Android API $androidVersion, using ${androidVersion >= 33 ? "READ_MEDIA_IMAGES" : "READ_EXTERNAL_STORAGE"}');
    
    // Check current status first
    var status = await permission.status;
    debugPrint('🔐 Current permission status: ${status.name}');
    
    // If not granted, request it
    if (!status.isGranted && !status.isLimited && !status.isPermanentlyDenied) {
      debugPrint('🔐 Requesting permission...');
      status = await permission.request();
      debugPrint('🔐 Permission request result: ${status.name}');
    }

    // Check if we have any form of access
    // On Android 11-12, status might be "granted" or "limited"
    // On Android 13+, we need READ_MEDIA_IMAGES to be granted
    final hasAccess = status.isGranted || status.isLimited;

    if (!hasAccess) {
      debugPrint('❌ Permission denied or restricted');

      if (context.mounted) {
        // Show dialog with option to open settings
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(
              status.isPermanentlyDenied
                  ? 'Photo access was permanently denied. Please enable it in settings to select images.'
                  : 'This app needs access to your photos to select images. Please grant permission.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(status.isPermanentlyDenied ? 'Open Settings' : 'Grant Permission'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          } else {
            // Try requesting again
            final newStatus = await permission.request();
            if (!newStatus.isGranted && !newStatus.isLimited) {
              return null;
            }
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    debugPrint('✅ Permission granted or limited access available');

    // Convert filter to RequestType
    RequestType requestType = RequestType.image;
    switch (config.filter) {
      case PickerFilter.images:
        requestType = RequestType.image;
        break;
      case PickerFilter.videos:
        requestType = RequestType.video;
        break;
      case PickerFilter.any:
        requestType = RequestType.common;
        break;
      case PickerFilter.livePhotos:
        requestType = RequestType.image; // Live photos not supported on Android
        break;
    }

    debugPrint('📱 Opening picker with maxAssets: ${config.selectionLimit == 0 ? 9999 : config.selectionLimit}');

    try {
      // Pick assets with custom configuration
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: config.selectionLimit == 0 ? 9999 : config.selectionLimit,
          requestType: requestType,
          specialPickerType: SpecialPickerType.noPreview, // Disable preview, tap to select
          selectPredicate: (BuildContext context, AssetEntity asset, bool isSelected) {
            // Allow selection directly
            return true;
          },
        ),
      );

      debugPrint('📱 Picker returned ${assets?.length ?? 0} assets');

      if (assets == null || assets.isEmpty) {
        return null;
      }

      // Convert AssetEntity to PhotoInfo
      debugPrint('🔄 Converting ${assets.length} assets to PhotoInfo...');
      final List<PhotoInfo> photoInfoList = [];
      for (final asset in assets) {
        final photoInfo = await _convertAssetToPhotoInfo(asset);
        if (photoInfo != null) {
          photoInfoList.add(photoInfo);
        }
      }

      debugPrint('✅ Converted ${photoInfoList.length} photos');
      return photoInfoList.isEmpty ? null : photoInfoList;
    } catch (e) {
      debugPrint('❌ Error in picker: $e');
      rethrow;
    }
  }

  /// Convert AssetEntity to PhotoInfo
  Future<PhotoInfo?> _convertAssetToPhotoInfo(AssetEntity asset) async {
    try {
      // Get file
      final file = await asset.file;
      if (file == null) return null;

      // Get image data
      final bytes = await file.readAsBytes();

      // Get file size
      final fileSize = bytes.length;
      final fileSizeFormatted = _formatBytes(fileSize.toDouble());

      // Get dimensions
      final width = asset.width;
      final height = asset.height;

      // Get file type
      String fileType = 'JPEG';
      if (asset.mimeType != null) {
        if (asset.mimeType!.contains('png')) {
          fileType = 'PNG';
        } else if (asset.mimeType!.contains('heic') || asset.mimeType!.contains('heif')) {
          fileType = 'HEIC';
        } else if (asset.mimeType!.contains('gif')) {
          fileType = 'GIF';
        } else if (asset.mimeType!.contains('webp')) {
          fileType = 'WEBP';
        }
      }

      // Get creation date
      final creationDate = asset.createDateTime.toIso8601String();

      // Get file name
      final fileName = asset.title ?? 'Image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return PhotoInfo(
        id: asset.id,
        fileName: fileName,
        fileSizeBytes: fileSize,
        fileSize: fileSizeFormatted,
        dimensions: PhotoDimensions(width: width, height: height),
        creationDate: creationDate,
        fileType: fileType,
        assetIdentifier: asset.id,
        imageData: bytes,
        scale: 1.0,
        orientation: ImageOrientation.up, // Android doesn't provide orientation easily
      );
    } catch (e) {
      debugPrint('Error converting asset to PhotoInfo: $e');
      return null;
    }
  }

  /// Format bytes to human readable string
  String _formatBytes(double bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '${bytes.toStringAsFixed(0)} bytes';
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      debugPrint('📱 Detected Android SDK version: $sdkInt');
      return sdkInt;
    } catch (e) {
      debugPrint('⚠️ Error getting Android version: $e, defaulting to API 30');
      return 30; // Default to Android 11 (safer default)
    }
  }

  /// Check the current photo access status
  ///
  /// Returns [PhotoAccessStatus] indicating the current permission state:
  /// - [PhotoAccessStatus.fullAccess]: User has granted full access
  /// - [PhotoAccessStatus.limitedAccess]: User has granted limited access (iOS 14+ only)
  /// - [PhotoAccessStatus.noAccess]: User has denied or not yet granted access
  ///
  /// **IMPORTANT - PHPicker on iOS:**
  /// - PHPicker does NOT require photo library permission to work
  /// - PHPicker always shows ALL photos to the user, regardless of permission status
  /// - The "limited access" status refers to PHAsset API access, NOT PHPicker
  /// - This method checks PHAsset permission, which is separate from PHPicker
  /// - You can use PHPicker even when this returns `noAccess` or `limitedAccess`
  ///
  /// **Use this method only if:**
  /// - You need to access PHAsset metadata (not provided by this plugin)
  /// - You want to show permission status in your UI
  /// - You're using other photo library features beyond picking
  ///
  /// **For Android:**
  /// - Permission IS required to use the picker
  /// - This method accurately reflects picker access
  ///
  /// Example:
  /// ```dart
  /// final picker = MetaPhotoPicker();
  /// final status = await picker.checkPhotoAccessStatus();
  ///
  /// switch (status) {
  ///   case PhotoAccessStatus.fullAccess:
  ///     print('✅ Full access granted');
  ///     break;
  ///   case PhotoAccessStatus.limitedAccess:
  ///     print('⚠️ Limited PHAsset access (iOS only - PHPicker still works!)');
  ///     break;
  ///   case PhotoAccessStatus.noAccess:
  ///     print('❌ No PHAsset access (iOS: PHPicker still works! Android: Need permission)');
  ///     break;
  /// }
  /// ```
  Future<PhotoAccessStatus> checkPhotoAccessStatus() async {
    if (Platform.isIOS) {
      // On iOS, check photos permission (for PHAsset API, NOT PHPicker)
      // PHPicker works regardless of this permission status
      final status = await Permission.photos.status;

      if (status.isGranted) {
        return PhotoAccessStatus.fullAccess;
      } else if (status.isLimited) {
        return PhotoAccessStatus.limitedAccess;
      } else {
        return PhotoAccessStatus.noAccess;
      }
    } else if (Platform.isAndroid) {
      // On Android, check appropriate permission based on version
      // This permission IS required for the picker to work
      final androidVersion = await _getAndroidVersion();
      final permission = androidVersion >= 33 ? Permission.photos : Permission.storage;
      final status = await permission.status;

      debugPrint('🔐 Android permission status: ${status.name}');

      if (status.isLimited) {
        return PhotoAccessStatus.limitedAccess;
      } else if (status.isGranted) {
        return PhotoAccessStatus.fullAccess;
      } else {
        return PhotoAccessStatus.noAccess;
      }
    }

    return PhotoAccessStatus.noAccess;
  }

  /// Request photo library permission
  ///
  /// Returns [PermissionStatus] indicating the result of the permission request.
  ///
  /// **IMPORTANT - iOS PHPicker:**
  /// - You do NOT need to call this method to use PHPicker on iOS
  /// - PHPicker works without any permission and shows ALL photos
  /// - This method requests PHAsset API permission (for direct library access)
  /// - Only call this if you need PHAsset metadata beyond what PHPicker provides
  ///
  /// **Android:**
  /// - Permission IS required for the picker to work
  /// - The plugin automatically requests permission when needed
  /// - You can call this method to request permission proactively
  ///
  /// Example:
  /// ```dart
  /// final picker = MetaPhotoPicker();
  /// 
  /// // On Android: Required for picker
  /// // On iOS: NOT required for PHPicker (only for PHAsset API)
  /// final status = await picker.requestPermission();
  ///
  /// if (status.isGranted || status.isLimited) {
  ///   print('✅ Permission granted');
  /// } else {
  ///   print('❌ Permission denied');
  /// }
  /// ```
  Future<PermissionStatus> requestPermission() async {
    if (Platform.isIOS) {
      return await Permission.photos.request();
    } else if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      final permission = androidVersion >= 33 ? Permission.photos : Permission.storage;
      return await permission.request();
    }

    return PermissionStatus.denied;
  }

  /// Check if photo library permission is granted
  ///
  /// Returns true if permission is granted (full or limited access), false otherwise.
  /// This is a convenience method that wraps [checkPhotoAccessStatus].
  ///
  /// **IMPORTANT - iOS PHPicker:**
  /// - This checks PHAsset API permission, NOT PHPicker access
  /// - PHPicker works even if this returns false
  /// - You do NOT need to check this before using `pickPhotos()` on iOS
  ///
  /// **Android:**
  /// - This accurately reflects picker access
  /// - Permission is required for picker to work
  ///
  /// Example:
  /// ```dart
  /// final picker = MetaPhotoPicker();
  /// 
  /// // On iOS: PHPicker works regardless of this check
  /// // On Android: This check is meaningful for picker access
  /// final hasPermission = await picker.isPermissionGranted();
  ///
  /// if (hasPermission) {
  ///   print('Has PHAsset/Storage permission');
  /// } else {
  ///   print('No permission (iOS: PHPicker still works!)');
  /// }
  /// ```
  Future<bool> isPermissionGranted() async {
    final status = await checkPhotoAccessStatus();
    return status == PhotoAccessStatus.fullAccess || status == PhotoAccessStatus.limitedAccess;
  }
}
