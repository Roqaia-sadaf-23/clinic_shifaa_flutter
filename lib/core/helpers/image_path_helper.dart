import '../constant/ApiLinks.dart';

const _invalidImagePaths = {'string', 'test', 'null'};
final _imageFileExtension = RegExp(
  r'\.(?:png|jpe?g|webp|gif)$',
  caseSensitive: false,
);

bool isValidImagePath(String? imagePath) {
  if (imagePath == null) return false;

  final value = imagePath.trim().toLowerCase();
  return value.isNotEmpty && !_invalidImagePaths.contains(value);
}

String? normalizeImagePath(String? imagePath) {
  if (!isValidImagePath(imagePath)) return null;
  return imagePath!.trim();
}

String? imageUrlForPath(String? imagePath) {
  final value = normalizeImagePath(imagePath);
  if (value == null) return null;

  final uri = Uri.tryParse(value);
  if (uri != null &&
      uri.hasScheme &&
      uri.host.isNotEmpty &&
      (uri.scheme == 'http' || uri.scheme == 'https')) {
    return value;
  }

  if ((uri?.hasScheme ?? false) || !_imageFileExtension.hasMatch(value)) {
    return null;
  }

  return '${ApiLinks.server}/Images/GetImage/${Uri.encodeComponent(value)}';
}
