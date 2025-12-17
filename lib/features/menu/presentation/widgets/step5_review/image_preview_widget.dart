import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Image preview widget for review screen
class ImagePreviewWidget extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewWidget({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 200,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildErrorPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 48),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.broken_image, size: 48),
    );
  }
}

