import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import 'meta_photo_picker_platform_interface.dart';
import 'models/photo_info.dart';
import 'models/picker_config.dart';

export 'models/photo_info.dart';
export 'models/picker_config.dart';

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

    // Request permission using permission_handler
    debugPrint('🔐 Requesting photo permission...');

    PermissionStatus status;

    // Check Android version and request appropriate permission
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
      // For Android 12 and below, use READ_EXTERNAL_STORAGE
      final androidInfo = await _getAndroidVersion();

      if (androidInfo >= 33) {
        debugPrint('📱 Android 13+ detected, requesting READ_MEDIA_IMAGES');
        status = await Permission.photos.request();
      } else {
        debugPrint('📱 Android 12 or below detected, requesting READ_EXTERNAL_STORAGE');
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.photos.request();
    }

    debugPrint('🔐 Permission status: ${status.name}');

    if (!status.isGranted && !status.isLimited) {
      debugPrint('❌ Permission denied or restricted');

      if (context.mounted) {
        // Show dialog with option to open settings
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'This app needs access to your photos to select images. '
              'Please grant permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
      }

      return null;
    }

    debugPrint('✅ Permission granted');

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
      // Try to get from device info
      // For now, we'll assume API 33+ and let permission_handler handle it
      return 33; // Default to Android 13+
    } catch (e) {
      debugPrint('Error getting Android version: $e');
      return 33;
    }
  }
}
