import 'meta_photo_picker_platform_interface.dart';
import 'models/photo_info.dart';
import 'models/picker_config.dart';

export 'models/photo_info.dart';
export 'models/picker_config.dart';

/// Main class for the Meta Photo Picker plugin
/// 
/// This plugin provides access to PHPicker on iOS for selecting photos
/// with detailed metadata information.
class MetaPhotoPicker {
  /// Gets the platform version
  Future<String?> getPlatformVersion() {
    return MetaPhotoPickerPlatform.instance.getPlatformVersion();
  }

  /// Opens the photo picker and returns a list of selected photos with detailed information
  /// 
  /// [config] - Configuration options for the picker (optional)
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
  /// final photos = await picker.pickPhotos(config: config);
  /// if (photos != null) {
  ///   for (var photo in photos) {
  ///     print('Selected: ${photo.fileName} (${photo.fileSize})');
  ///   }
  /// }
  /// ```
  Future<List<PhotoInfo>?> pickPhotos({PickerConfig? config}) {
    return MetaPhotoPickerPlatform.instance.pickPhotos(
      config: config ?? PickerConfig(),
    );
  }

  /// Opens the photo picker for selecting a single photo
  /// 
  /// This is a convenience method that sets selectionLimit to 1 and returns
  /// a single [PhotoInfo] object instead of a list.
  /// 
  /// Returns a [PhotoInfo] object with detailed information about the selected photo,
  /// or null if the user cancels the picker.
  /// 
  /// Example:
  /// ```dart
  /// final picker = MetaPhotoPicker();
  /// final photo = await picker.pickSinglePhoto();
  /// if (photo != null) {
  ///   print('Selected: ${photo.fileName}');
  /// }
  /// ```
  Future<PhotoInfo?> pickSinglePhoto({PickerConfig? config}) async {
    final modifiedConfig = (config ?? PickerConfig()).copyWith(selectionLimit: 1);
    final photos = await pickPhotos(config: modifiedConfig);
    return photos?.isNotEmpty == true ? photos!.first : null;
  }
}
