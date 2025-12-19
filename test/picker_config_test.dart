import 'package:flutter_test/flutter_test.dart';
import 'package:meta_photo_picker/models/picker_config.dart';

void main() {
  group('PickerConfig', () {
    test('creates with default values', () {
      final config = PickerConfig();

      expect(config.selectionLimit, 1);
      expect(config.filter, PickerFilter.images);
      expect(config.preferredAssetRepresentationMode, AssetRepresentationMode.current);
      expect(config.compressionQuality, 1.0);
    });

    test('creates with custom values', () {
      final config = PickerConfig(
        selectionLimit: 5,
        filter: PickerFilter.videos,
        preferredAssetRepresentationMode: AssetRepresentationMode.compatible,
        compressionQuality: 0.9,
      );

      expect(config.selectionLimit, 5);
      expect(config.filter, PickerFilter.videos);
      expect(config.preferredAssetRepresentationMode, AssetRepresentationMode.compatible);
      expect(config.compressionQuality, 0.9);
    });

    test('toJson creates valid JSON map', () {
      final config = PickerConfig(
        selectionLimit: 10,
        filter: PickerFilter.livePhotos,
        preferredAssetRepresentationMode: AssetRepresentationMode.automatic,
        compressionQuality: 0.7,
      );

      final json = config.toJson();

      expect(json['selectionLimit'], 10);
      expect(json['filter'], 'livePhotos');
      expect(json['preferredAssetRepresentationMode'], 'automatic');
      expect(json['compressionQuality'], 0.7);
    });

    test('copyWith creates new instance with updated values', () {
      final config = PickerConfig(
        selectionLimit: 1,
        filter: PickerFilter.images,
      );

      final updated = config.copyWith(
        selectionLimit: 5,
        compressionQuality: 0.9,
      );

      expect(updated.selectionLimit, 5);
      expect(updated.filter, PickerFilter.images); // unchanged
      expect(updated.compressionQuality, 0.9);
      expect(updated.preferredAssetRepresentationMode, AssetRepresentationMode.current); // unchanged
    });

    test('throws assertion error for negative selection limit', () {
      expect(
        () => PickerConfig(selectionLimit: -1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws assertion error for invalid compression quality', () {
      expect(
        () => PickerConfig(compressionQuality: -0.1),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => PickerConfig(compressionQuality: 1.1),
        throwsA(isA<AssertionError>()),
      );
    });

    test('allows zero selection limit (unlimited)', () {
      final config = PickerConfig(selectionLimit: 0);
      expect(config.selectionLimit, 0);
    });

    test('allows boundary compression quality values', () {
      final config1 = PickerConfig(compressionQuality: 0.0);
      expect(config1.compressionQuality, 0.0);

      final config2 = PickerConfig(compressionQuality: 1.0);
      expect(config2.compressionQuality, 1.0);
    });
  });

  group('PickerFilter', () {
    test('has correct values', () {
      expect(PickerFilter.images.value, 'images');
      expect(PickerFilter.videos.value, 'videos');
      expect(PickerFilter.livePhotos.value, 'livePhotos');
      expect(PickerFilter.any.value, 'any');
    });

    test('toString returns value', () {
      expect(PickerFilter.images.toString(), 'images');
      expect(PickerFilter.videos.toString(), 'videos');
      expect(PickerFilter.livePhotos.toString(), 'livePhotos');
      expect(PickerFilter.any.toString(), 'any');
    });
  });

  group('AssetRepresentationMode', () {
    test('has correct values', () {
      expect(AssetRepresentationMode.automatic.value, 'automatic');
      expect(AssetRepresentationMode.current.value, 'current');
      expect(AssetRepresentationMode.compatible.value, 'compatible');
    });

    test('toString returns value', () {
      expect(AssetRepresentationMode.automatic.toString(), 'automatic');
      expect(AssetRepresentationMode.current.toString(), 'current');
      expect(AssetRepresentationMode.compatible.toString(), 'compatible');
    });
  });
}

