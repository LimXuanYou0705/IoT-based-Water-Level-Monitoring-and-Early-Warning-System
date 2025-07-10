import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final double radius;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.localFile,
    this.radius = 50,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (localFile != null) {
      image = CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(localFile!),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Center(
                  child: SizedBox(
                    width: radius * 2,
                    height: radius * 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.1).round()),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            errorWidget: (context, url, error) => _fallback(),
          ),
        ),
      );
    } else {
      image = _fallback();
    }

    return image;
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade700,
      child: Icon(Icons.person, size: radius, color: Colors.white),
    );
  }
}
