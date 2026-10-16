import 'package:flutter/material.dart';

/// Ürün görselini ağdan yükler; yüklenemezse yerel yer tutucu görseli
/// (`Image.asset`) gösterir.
class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, this.fit = BoxFit.contain});

  static const String placeholderAsset = 'assets/images/placeholder.png';

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Image.asset(placeholderAsset, fit: BoxFit.cover);
    }

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(placeholderAsset, fit: BoxFit.cover),
    );
  }
}
