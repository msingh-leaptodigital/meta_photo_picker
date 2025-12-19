import 'package:flutter_test/flutter_test.dart';
import 'package:meta_photo_picker/meta_photo_picker.dart';
import 'package:meta_photo_picker/meta_photo_picker_platform_interface.dart';
import 'package:meta_photo_picker/meta_photo_picker_method_channel.dart';
import 'package:meta_photo_picker/models/photo_info.dart';
import 'package:meta_photo_picker/models/picker_config.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMetaPhotoPickerPlatform
    with MockPlatformInterfaceMixin
    implements MetaPhotoPickerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<PhotoInfo>?> pickPhotos({required PickerConfig config}) {
    return Future.value([
      PhotoInfo(
        id: 'test-id',
        fileName: 'test.jpg',
        fileSizeBytes: 1024,
        fileSize: '1 KB',
        dimensions: PhotoDimensions(width: 100, height: 100),
        fileType: 'JPEG',
        imageData: [1, 2, 3],
        scale: 1.0,
        orientation: ImageOrientation.up,
      ),
    ]);
  }
}

void main() {
  final MetaPhotoPickerPlatform initialPlatform = MetaPhotoPickerPlatform.instance;

  test('$MethodChannelMetaPhotoPicker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMetaPhotoPicker>());
  });

  test('getPlatformVersion', () async {
    MetaPhotoPicker metaPhotoPickerPlugin = MetaPhotoPicker();
    MockMetaPhotoPickerPlatform fakePlatform = MockMetaPhotoPickerPlatform();
    MetaPhotoPickerPlatform.instance = fakePlatform;

    expect(await metaPhotoPickerPlugin.getPlatformVersion(), '42');
  });

  test('pickPhotos returns list of PhotoInfo', () async {
    MetaPhotoPicker metaPhotoPickerPlugin = MetaPhotoPicker();
    MockMetaPhotoPickerPlatform fakePlatform = MockMetaPhotoPickerPlatform();
    MetaPhotoPickerPlatform.instance = fakePlatform;

    final photos = await metaPhotoPickerPlugin.pickPhotos();
    
    expect(photos, isNotNull);
    expect(photos!.length, 1);
    expect(photos.first.fileName, 'test.jpg');
    expect(photos.first.fileType, 'JPEG');
  });

  test('pickSinglePhoto returns single PhotoInfo', () async {
    MetaPhotoPicker metaPhotoPickerPlugin = MetaPhotoPicker();
    MockMetaPhotoPickerPlatform fakePlatform = MockMetaPhotoPickerPlatform();
    MetaPhotoPickerPlatform.instance = fakePlatform;

    final photo = await metaPhotoPickerPlugin.pickSinglePhoto();
    
    expect(photo, isNotNull);
    expect(photo!.fileName, 'test.jpg');
    expect(photo.fileType, 'JPEG');
  });
}
