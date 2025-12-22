import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'meta_photo_picker_platform_interface.dart';
import 'models/photo_info.dart';
import 'models/picker_config.dart';

/// An implementation of [MetaPhotoPickerPlatform] that uses method channels.
class MethodChannelMetaPhotoPicker extends MetaPhotoPickerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('meta_photo_picker');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<PhotoInfo>?> pickPhotos({
    required PickerConfig config,
    VoidCallback? onLoadStarted,
    VoidCallback? onLoadEnded,
  }) async {
    // Set up method call handler for events
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onLoadStarted':
          onLoadStarted?.call();
          break;
        case 'onLoadEnded':
          onLoadEnded?.call();
          break;
      }
    });

    try {
      final result = await methodChannel.invokeMethod<List<dynamic>>(
        'pickPhotos',
        config.toJson(),
      );

      if (result == null) {
        return null; // User cancelled
      }

      return result.map((item) {
        // Safely convert the nested map structure
        final map = item as Map;
        final convertedMap = <String, dynamic>{};
        
        map.forEach((key, value) {
          final stringKey = key.toString();
          
          // Handle nested maps (like dimensions)
          if (value is Map) {
            final nestedMap = <String, dynamic>{};
            value.forEach((k, v) {
              nestedMap[k.toString()] = v;
            });
            convertedMap[stringKey] = nestedMap;
          } else {
            convertedMap[stringKey] = value;
          }
        });
        
        return PhotoInfo.fromJson(convertedMap);
      }).toList();
    } on PlatformException catch (e) {
      debugPrint('Error picking photos: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error parsing photo data: $e');
      rethrow;
    } finally {
      // Clean up handler
      methodChannel.setMethodCallHandler(null);
    }
  }
}
