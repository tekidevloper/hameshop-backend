import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Skeleton loader for product cards
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            color: Colors.grey[300],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Star rating widget
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showRating;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, size: size, color: starColor);
          } else if (index < rating) {
            return Icon(Icons.star_half, size: size, color: starColor);
          } else {
            return Icon(Icons.star_border, size: size, color: starColor);
          }
        }),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size * 0.8, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _buildPlaceholder();

    final isBase64 = imageUrl.startsWith('data:') || 
                    (!imageUrl.startsWith('http') && imageUrl.length > 50);

    if (isBase64) {
      try {
        String base64Data = imageUrl;
        if (base64Data.contains(',')) {
          base64Data = base64Data.split(',').last;
        }
        
        // Clean the base64 string
        base64Data = base64Data.trim().replaceAll(RegExp(r'[\s\n\r]'), '');
        
        // Fix common base64 character issues
        base64Data = base64Data.replaceAll('-', '+').replaceAll('_', '/');
        
        // Ensure proper padding
        while (base64Data.length % 4 != 0) {
          base64Data += '=';
        }

        return Image.memory(
          base64Decode(base64Data),
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('ProductImage base64 error: $error');
            return _buildPlaceholder();
          },
        );
      } catch (e) {
        debugPrint('ProductImage base64 catch error: $e');
        return _buildPlaceholder();
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(isLoading: true),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : placeholder ?? const Icon(Icons.image_outlined, color: Colors.grey, size: 30),
      ),
    );
  }
}
