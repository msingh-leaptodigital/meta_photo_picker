import 'package:flutter_test/flutter_test.dart';
import 'package:meta_photo_picker/models/photo_info.dart';

void main() {
  group('PhotoInfo', () {
    test('fromJson creates valid PhotoInfo object', () {
      final json = {
        'id': 'test-id-123',
        'fileName': 'test.jpg',
        'fileSizeBytes': 1024000,
        'fileSize': '1.00 MB',
        'dimensions': {
          'width': 1920,
          'height': 1080,
        },
        'creationDate': '2024-01-15T10:30:00Z',
        'fileType': 'JPEG',
        'assetIdentifier': 'asset-123',
        'imageData': [1, 2, 3, 4, 5],
        'scale': 2.0,
        'orientation': 'Up',
      };

      final photoInfo = PhotoInfo.fromJson(json);

      expect(photoInfo.id, 'test-id-123');
      expect(photoInfo.fileName, 'test.jpg');
      expect(photoInfo.fileSizeBytes, 1024000);
      expect(photoInfo.fileSize, '1.00 MB');
      expect(photoInfo.dimensions.width, 1920);
      expect(photoInfo.dimensions.height, 1080);
      expect(photoInfo.creationDate, '2024-01-15T10:30:00Z');
      expect(photoInfo.fileType, 'JPEG');
      expect(photoInfo.assetIdentifier, 'asset-123');
      expect(photoInfo.imageData, [1, 2, 3, 4, 5]);
      expect(photoInfo.scale, 2.0);
      expect(photoInfo.orientation, ImageOrientation.up);
    });

    test('toJson creates valid JSON map', () {
      final photoInfo = PhotoInfo(
        id: 'test-id-456',
        fileName: 'photo.png',
        fileSizeBytes: 2048000,
        fileSize: '2.00 MB',
        dimensions: PhotoDimensions(width: 3840, height: 2160),
        creationDate: '2024-02-20T15:45:00Z',
        fileType: 'PNG',
        assetIdentifier: 'asset-456',
        imageData: [10, 20, 30],
        scale: 3.0,
        orientation: ImageOrientation.right,
      );

      final json = photoInfo.toJson();

      expect(json['id'], 'test-id-456');
      expect(json['fileName'], 'photo.png');
      expect(json['fileSizeBytes'], 2048000);
      expect(json['fileSize'], '2.00 MB');
      expect(json['dimensions']['width'], 3840);
      expect(json['dimensions']['height'], 2160);
      expect(json['creationDate'], '2024-02-20T15:45:00Z');
      expect(json['fileType'], 'PNG');
      expect(json['assetIdentifier'], 'asset-456');
      expect(json['imageData'], [10, 20, 30]);
      expect(json['scale'], 3.0);
      expect(json['orientation'], 'Right');
    });

    test('aspectRatio calculates correctly', () {
      final photoInfo = PhotoInfo(
        id: 'test',
        fileName: 'test.jpg',
        fileSizeBytes: 1000,
        fileSize: '1 KB',
        dimensions: PhotoDimensions(width: 1920, height: 1080),
        fileType: 'JPEG',
        imageData: [],
        scale: 1.0,
        orientation: ImageOrientation.up,
      );

      expect(photoInfo.aspectRatio, closeTo(1.777, 0.001));
    });
  });

  group('PhotoDimensions', () {
    test('fromJson creates valid PhotoDimensions', () {
      final json = {'width': 1024, 'height': 768};
      final dimensions = PhotoDimensions.fromJson(json);

      expect(dimensions.width, 1024);
      expect(dimensions.height, 768);
    });

    test('toJson creates valid JSON map', () {
      final dimensions = PhotoDimensions(width: 2048, height: 1536);
      final json = dimensions.toJson();

      expect(json['width'], 2048);
      expect(json['height'], 1536);
    });

    test('toString formats correctly', () {
      final dimensions = PhotoDimensions(width: 1920, height: 1080);
      expect(dimensions.toString(), '1920 × 1080 px');
    });
  });

  group('ImageOrientation', () {
    test('fromString parses all orientations correctly', () {
      expect(ImageOrientation.fromString('up'), ImageOrientation.up);
      expect(ImageOrientation.fromString('down'), ImageOrientation.down);
      expect(ImageOrientation.fromString('left'), ImageOrientation.left);
      expect(ImageOrientation.fromString('right'), ImageOrientation.right);
      expect(ImageOrientation.fromString('upmirrored'), ImageOrientation.upMirrored);
      expect(ImageOrientation.fromString('downmirrored'), ImageOrientation.downMirrored);
      expect(ImageOrientation.fromString('leftmirrored'), ImageOrientation.leftMirrored);
      expect(ImageOrientation.fromString('rightmirrored'), ImageOrientation.rightMirrored);
      expect(ImageOrientation.fromString('invalid'), ImageOrientation.unknown);
    });

    test('toString formats correctly', () {
      expect(ImageOrientation.up.toString(), 'Up');
      expect(ImageOrientation.down.toString(), 'Down');
      expect(ImageOrientation.left.toString(), 'Left');
      expect(ImageOrientation.right.toString(), 'Right');
      expect(ImageOrientation.upMirrored.toString(), 'Up Mirrored');
      expect(ImageOrientation.downMirrored.toString(), 'Down Mirrored');
      expect(ImageOrientation.leftMirrored.toString(), 'Left Mirrored');
      expect(ImageOrientation.rightMirrored.toString(), 'Right Mirrored');
      expect(ImageOrientation.unknown.toString(), 'Unknown');
    });
  });
}

