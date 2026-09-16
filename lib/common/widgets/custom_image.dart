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

  int? _cachePx(double? logical) {
    if (logical == null || logical <= 0 || logical.isInfinite) {
      return null;
    }
    final dpr = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    return (logical * dpr).round().clamp(1, 1080);
  }

  @override
  Widget build(BuildContext context) {
    final url = image ?? '';
    if (url.isEmpty || !(url.startsWith('http://') || url.startsWith('https://'))) {
      return _fallback();
    }

    if (kIsWeb) {
      return Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    final memW = _cachePx(width);
    final memH = width == null ? _cachePx(height) : null;

    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: memW,
      memCacheHeight: memH,
      maxWidthDiskCache: memW,
      maxHeightDiskCache: memH,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      useOldImageOnUrlChange: true,
      placeholder: (_, __) => _fallback(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }
}
