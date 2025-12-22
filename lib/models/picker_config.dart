/// Configuration options for the PHPicker
class PickerConfig {
  /// Maximum number of photos that can be selected
  /// Set to 0 for unlimited selection
  final int selectionLimit;

  /// Filter for the types of assets to display
  final PickerFilter filter;

  /// Preferred asset representation mode
  final AssetRepresentationMode preferredAssetRepresentationMode;

  /// Quality of JPEG compression (0.0 to 1.0)
  /// Only applicable when converting images to JPEG
  /// Default is 1.0 (no compression, maximum quality)
  final double compressionQuality;

  /// Optional directory path where selected photos should be saved.
  /// If provided, photos will be copied to this directory with their original names.
  /// Duplicate file names will be handled by appending a counter (e.g., "Image (1).jpg").
  /// If null, photos will be saved to a temporary directory.
  final String? destinationDirectory;

  PickerConfig({
    this.selectionLimit = 1,
    this.filter = PickerFilter.images,
    this.preferredAssetRepresentationMode = AssetRepresentationMode.current,
    this.compressionQuality = 1.0,
    this.destinationDirectory,
  }) : assert(selectionLimit >= 0, 'Selection limit must be non-negative'),
       assert(compressionQuality >= 0.0 && compressionQuality <= 1.0, 
              'Compression quality must be between 0.0 and 1.0');

  /// Converts the PickerConfig instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'selectionLimit': selectionLimit,
      'filter': filter.value,
      'preferredAssetRepresentationMode': preferredAssetRepresentationMode.value,
      'compressionQuality': compressionQuality,
      'destinationDirectory': destinationDirectory,
    };
  }

  /// Creates a copy of this config with the given fields replaced
  PickerConfig copyWith({
    int? selectionLimit,
    PickerFilter? filter,
    AssetRepresentationMode? preferredAssetRepresentationMode,
    double? compressionQuality,
    String? destinationDirectory,
  }) {
    return PickerConfig(
      selectionLimit: selectionLimit ?? this.selectionLimit,
      filter: filter ?? this.filter,
      preferredAssetRepresentationMode: preferredAssetRepresentationMode ?? 
          this.preferredAssetRepresentationMode,
      compressionQuality: compressionQuality ?? this.compressionQuality,
      destinationDirectory: destinationDirectory ?? this.destinationDirectory,
    );
  }

  @override
  String toString() {
    return 'PickerConfig(selectionLimit: $selectionLimit, filter: $filter, '
        'mode: $preferredAssetRepresentationMode, quality: $compressionQuality, '
        'destinationDirectory: $destinationDirectory)';
  }
}

/// Filter types for PHPicker
enum PickerFilter {
  /// Show only images
  images('images'),

  /// Show only videos
  videos('videos'),

  /// Show only live photos
  livePhotos('livePhotos'),

  /// Show all media types
  any('any');

  final String value;

  const PickerFilter(this.value);

  @override
  String toString() => value;
}

/// Asset representation mode for PHPicker
enum AssetRepresentationMode {
  /// Automatic mode - system decides the best representation
  automatic('automatic'),

  /// Current representation - uses the current format
  current('current'),

  /// Compatible representation - converts to compatible format
  compatible('compatible');

  final String value;

  const AssetRepresentationMode(this.value);

  @override
  String toString() => value;
}

