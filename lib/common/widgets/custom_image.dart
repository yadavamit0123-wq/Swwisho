import 'package:demandium/utils/core_export.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BoxFit? placeHolderBoxFit;
  final String? placeholder;
  const CustomImage({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder, this.placeHolderBoxFit });

  Widget _fallback() {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0xFF98A2B3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = image ?? '';
    if (url.isEmpty || !(url.startsWith('http://') || url.startsWith('https://'))) {
      return _fallback();
    }

    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return _fallback();
      },
    );
  }
}
