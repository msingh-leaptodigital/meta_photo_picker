import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'meta_photo_picker_method_channel.dart';
import 'models/photo_info.dart';
import 'models/picker_config.dart';

abstract class MetaPhotoPickerPlatform extends PlatformInterface {
  /// Constructs a MetaPhotoPickerPlatform.
  MetaPhotoPickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static MetaPhotoPickerPlatform _instance = MethodChannelMetaPhotoPicker();

  /// The default instance of [MetaPhotoPickerPlatform] to use.
  ///
  /// Defaults to [MethodChannelMetaPhotoPicker].
  static MetaPhotoPickerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MetaPhotoPickerPlatform] when
  /// they register themselves.
  static set instance(MetaPhotoPickerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Opens the photo picker and returns selected photos with detailed information
  Future<List<PhotoInfo>?> pickPhotos({required PickerConfig config}) {
    throw UnimplementedError('pickPhotos() has not been implemented.');
  }

  /// Checks the native photo permission status (Android only)
  Future<String?> checkPhotoPermission() {
    throw UnimplementedError('checkPhotoPermission() has not been implemented.');
  }
}
