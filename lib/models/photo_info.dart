/// Represents detailed information about a selected photo
class PhotoInfo {
  /// Unique identifier for the photo
  final String id;

  /// File name of the photo
  final String fileName;

  /// File size in bytes
  final int fileSizeBytes;

  /// Formatted file size string (e.g., "2.5 MB")
  final String fileSize;

  /// Image dimensions in pixels
  final PhotoDimensions dimensions;

  /// Creation date of the photo (ISO 8601 format)
  final String? creationDate;

  /// File type/format (e.g., "JPEG", "PNG", "HEIC")
  final String fileType;

  /// Asset identifier from Photos library
  final String? assetIdentifier;

  /// Path to the temporary file
  final String? filePath;

  /// Image data as bytes (optional, may be null if filePath is used)
  final List<int>? imageData;

  /// Image scale factor
  final double scale;

  /// Image orientation
  final ImageOrientation orientation;

  PhotoInfo({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.fileSize,
    required this.dimensions,
    this.creationDate,
    required this.fileType,
    this.assetIdentifier,
    this.filePath,
    this.imageData,
    required this.scale,
    required this.orientation,
  });

  /// Creates a PhotoInfo instance from a JSON map
  factory PhotoInfo.fromJson(Map<String, dynamic> json) {
    return PhotoInfo(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      fileSize: json['fileSize'] as String,
      dimensions: PhotoDimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
      creationDate: json['creationDate'] as String?,
      fileType: json['fileType'] as String,
      assetIdentifier: json['assetIdentifier'] as String?,
      filePath: json['filePath'] as String?,
      imageData: json['imageData'] != null ? List<int>.from(json['imageData'] as List) : null,
      scale: (json['scale'] as num).toDouble(),
      orientation: ImageOrientation.fromString(json['orientation'] as String),
    );
  }

  /// Converts the PhotoInfo instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'fileSize': fileSize,
      'dimensions': dimensions.toJson(),
      'creationDate': creationDate,
      'fileType': fileType,
      'assetIdentifier': assetIdentifier,
      'filePath': filePath,
      'imageData': imageData,
      'scale': scale,
      'orientation': orientation.toString(),
    };
  }

  /// Gets the aspect ratio of the image
  double get aspectRatio => dimensions.width / dimensions.height;

  @override
  String toString() {
    return 'PhotoInfo(fileName: $fileName, fileSize: $fileSize, dimensions: $dimensions, fileType: $fileType)';
  }
}

/// Represents the dimensions of a photo
class PhotoDimensions {
  /// Width in pixels
  final int width;

  /// Height in pixels
  final int height;

  PhotoDimensions({
    required this.width,
    required this.height,
  });

  /// Creates a PhotoDimensions instance from a JSON map
  factory PhotoDimensions.fromJson(Map<String, dynamic> json) {
    return PhotoDimensions(
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  /// Converts the PhotoDimensions instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  @override
  String toString() => '$width × $height px';
}

/// Represents the orientation of an image
enum ImageOrientation {
  up,
  down,
  left,
  right,
  upMirrored,
  downMirrored,
  leftMirrored,
  rightMirrored,
  unknown;

  /// Creates an ImageOrientation from a string value
  static ImageOrientation fromString(String value) {
    switch (value.toLowerCase()) {
      case 'up':
        return ImageOrientation.up;
      case 'down':
        return ImageOrientation.down;
      case 'left':
        return ImageOrientation.left;
      case 'right':
        return ImageOrientation.right;
      case 'upmirrored':
        return ImageOrientation.upMirrored;
      case 'downmirrored':
        return ImageOrientation.downMirrored;
      case 'leftmirrored':
        return ImageOrientation.leftMirrored;
      case 'rightmirrored':
        return ImageOrientation.rightMirrored;
      default:
        return ImageOrientation.unknown;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ImageOrientation.up:
        return 'Up';
      case ImageOrientation.down:
        return 'Down';
      case ImageOrientation.left:
        return 'Left';
      case ImageOrientation.right:
        return 'Right';
      case ImageOrientation.upMirrored:
        return 'Up Mirrored';
      case ImageOrientation.downMirrored:
        return 'Down Mirrored';
      case ImageOrientation.leftMirrored:
        return 'Left Mirrored';
      case ImageOrientation.rightMirrored:
        return 'Right Mirrored';
      case ImageOrientation.unknown:
        return 'Unknown';
    }
  }
}

