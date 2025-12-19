import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta_photo_picker/meta_photo_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PHPicker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PhotoPickerDemo(),
    );
  }
}

class PhotoPickerDemo extends StatefulWidget {
  const PhotoPickerDemo({super.key});

  @override
  State<PhotoPickerDemo> createState() => _PhotoPickerDemoState();
}

class _PhotoPickerDemoState extends State<PhotoPickerDemo> {
  final _metaPhotoPickerPlugin = MetaPhotoPicker();
  List<PhotoInfo> _selectedPhotos = [];
  bool _isLoading = false;

  Future<void> _pickPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final config = PickerConfig(
        selectionLimit: 0, // Unlimited selection
        filter: PickerFilter.images,
        preferredAssetRepresentationMode: AssetRepresentationMode.current,
        compressionQuality: 1.0, // No compression
      );

      final photos = await _metaPhotoPickerPlugin.pickPhotos(
        config: config,
        context: context, // Pass context for Android
      );

      debugPrint('📸 Picked ${photos?.length ?? 0} photos');
      
      if (photos != null && mounted) {
        setState(() {
          _selectedPhotos.addAll(photos);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${photos.length} photo(s)')),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Error picking photos: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickSinglePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final config = PickerConfig(
        selectionLimit: 1,
        filter: PickerFilter.images,
        preferredAssetRepresentationMode: AssetRepresentationMode.current,
        compressionQuality: 1.0, // No compression
      );
      
      final photo = await _metaPhotoPickerPlugin.pickSinglePhoto(
        config: config,
        context: context, // Pass context for Android
      );

      debugPrint('📸 Picked single photo: ${photo?.fileName}');
      
      if (photo != null && mounted) {
        setState(() {
          _selectedPhotos.add(photo);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${photo.fileName}')),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Error picking photo: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearAll() {
    setState(() {
      _selectedPhotos.clear();
    });
  }

  void _deletePhoto(String id) {
    setState(() {
      _selectedPhotos.removeWhere((photo) => photo.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PHPicker Demo'),
        actions: [
          if (_selectedPhotos.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedPhotos.isEmpty
              ? _buildEmptyState()
              : _buildPhotoList(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickSinglePhoto,
                icon: const Icon(Icons.photo),
                label: const Text('Pick Single Photo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickPhotos,
                icon: const Icon(Icons.photo_library),
                label: Text(_selectedPhotos.isEmpty
                    ? 'Select Photos'
                    : 'Add More Photos'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No images selected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to select photos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedPhotos.length,
      itemBuilder: (context, index) {
        final photo = _selectedPhotos[index];
        return PhotoCard(
          photo: photo,
          onDelete: () => _deletePhoto(photo.id),
          onTap: () => _showPhotoDetail(photo),
        );
      },
    );
  }

  void _showPhotoDetail(PhotoInfo photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(photo: photo),
      ),
    );
  }
}

class PhotoCard extends StatelessWidget {
  final PhotoInfo photo;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PhotoCard({
    super.key,
    required this.photo,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          GestureDetector(
            onTap: onTap,
            child: Image.memory(
              Uint8List.fromList(photo.imageData),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Photo Information
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.photo, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        photo.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.description,
                        label: photo.fileSize,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.aspect_ratio,
                        label: photo.dimensions.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (photo.creationDate != null)
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: _formatDate(photo.creationDate!),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.image,
                      label: photo.fileType,
                    ),
                    const Spacer(),
                    Text(
                      'Tap for details',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM d, y • h:mm a').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final PhotoInfo photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Image
            Image.memory(
              Uint8List.fromList(photo.imageData),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            // Detailed Information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.photo,
                    title: 'File Name',
                    value: photo.fileName,
                  ),
                  _DetailRow(
                    icon: Icons.description,
                    title: 'File Size',
                    value: photo.fileSize,
                  ),
                  _DetailRow(
                    icon: Icons.aspect_ratio,
                    title: 'Dimensions',
                    value: photo.dimensions.toString(),
                  ),
                  _DetailRow(
                    icon: Icons.image,
                    title: 'File Type',
                    value: photo.fileType,
                  ),
                  if (photo.creationDate != null)
                    _DetailRow(
                      icon: Icons.calendar_today,
                      title: 'Creation Date',
                      value: _formatDate(photo.creationDate!),
                    ),
                  if (photo.assetIdentifier != null)
                    _DetailRow(
                      icon: Icons.fingerprint,
                      title: 'Asset ID',
                      value: photo.assetIdentifier!,
                    ),
                  const Divider(height: 32),
                  Text(
                    'Image Properties',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.crop,
                    title: 'Aspect Ratio',
                    value: photo.aspectRatio.toStringAsFixed(2),
                  ),
                  _DetailRow(
                    icon: Icons.zoom_in,
                    title: 'Scale',
                    value: '${photo.scale}x',
                  ),
                  _DetailRow(
                    icon: Icons.screen_rotation,
                    title: 'Orientation',
                    value: photo.orientation.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMMM d, y • h:mm:ss a').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
