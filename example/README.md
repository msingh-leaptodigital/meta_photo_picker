# meta_photo_picker Example App

This example demonstrates how to use the `meta_photo_picker` plugin to select images from the photo library with detailed metadata.

## Features Demonstrated

### 1. Single Photo Selection
- Pick one photo at a time
- Get detailed information about the selected photo

### 2. Multiple Photo Selection
- Select multiple photos (unlimited)
- View all selected photos in a scrollable list

### 3. Photo Information Display
- **File Details**: Name, size, type
- **Image Properties**: Dimensions, aspect ratio, scale, orientation
- **Metadata**: Creation date, asset identifier

### 4. Photo Management
- View photo details in a dedicated screen
- Delete individual photos
- Clear all selected photos

## UI Components

### Main Screen
- Empty state with instructions
- Scrollable list of selected photos
- Two action buttons:
  - "Pick Single Photo" - Select one photo
  - "Select Photos" / "Add More Photos" - Select multiple photos
- "Clear All" button in app bar (when photos are selected)

### Photo Card
Each photo is displayed in a card showing:
- Image preview (tap to view details)
- File name
- File size
- Dimensions
- Creation date (if available)
- File type
- Delete button

### Photo Detail Screen
Full-screen view with:
- Large image preview
- Complete metadata information
- Image properties (aspect ratio, scale, orientation)

## Running the Example

1. Navigate to the example directory:
```bash
cd example
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on iOS device or simulator (iOS 14+):
```bash
flutter run
```

## Code Structure

### main.dart
- `PhotoPickerDemo`: Main screen with photo selection
- `PhotoCard`: Reusable card component for displaying photos
- `PhotoDetailScreen`: Full-screen photo detail view
- `_InfoChip`: Small info display component
- `_DetailRow`: Detail information row component

## Configuration Example

The example uses the following configuration:

```dart
final config = PickerConfig(
  selectionLimit: 0, // Unlimited selection
  filter: PickerFilter.images,
  preferredAssetRepresentationMode: AssetRepresentationMode.current,
  compressionQuality: 0.8,
);
```

You can modify these values to test different configurations:
- Change `selectionLimit` to limit the number of photos
- Try different `filter` options (images, videos, livePhotos, any)
- Test different `preferredAssetRepresentationMode` values
- Adjust `compressionQuality` for different file sizes

## Requirements

- iOS 14.0 or later
- Xcode 12.0 or later
- Flutter 3.3.0 or later

## Notes

- The app requires photo library access permission
- Images are loaded into memory, so be mindful of memory usage with large images
- The example uses the `intl` package for date formatting
