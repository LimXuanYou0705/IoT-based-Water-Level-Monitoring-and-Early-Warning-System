import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'avatar_widget.dart';

class ChangePhotoWidget extends StatefulWidget {
  final String? imageUrl; // URL or file path
  final double radius;
  final Future<void> Function(File file)
  onImageSelected; // Callback when new image selected

  const ChangePhotoWidget({
    super.key,
    this.imageUrl,
    this.radius = 50,
    required this.onImageSelected,
  });

  @override
  State<ChangePhotoWidget> createState() => _ChangePhotoWidgetState();
}

class _ChangePhotoWidgetState extends State<ChangePhotoWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  bool _isUploading = false;

  // Opens image picker from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      _isUploading = true;
      _selectedFile = file;
    });

    try {
      await widget.onImageSelected(file);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AvatarWidget(
            imageUrl: widget.imageUrl,
            localFile: _selectedFile,
            radius: widget.radius,
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
