// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../../../core/helpers/image_path_helper.dart';

class AppProfileImage extends StatelessWidget {
  const AppProfileImage({
    super.key,
    required this.imagePath,
    required this.size,
    required this.fallback,
    this.backgroundColor = Colors.transparent,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.loadingIndicatorColor,
  });

  final String? imagePath;
  final double size;
  final Widget fallback;
  final Color backgroundColor;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? loadingIndicatorColor;

  @override
  Widget build(BuildContext context) {
    final imageUrl = imageUrlForPath(imagePath);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: backgroundColor,
          child: imageUrl == null
              ? _fallback()
              : Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: fit,
                  errorBuilder: (_, _, _) => _fallback(),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: SizedBox.square(
                        dimension: size.clamp(18, 24),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: loadingIndicatorColor,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _fallback() => SizedBox.expand(child: fallback);
}
