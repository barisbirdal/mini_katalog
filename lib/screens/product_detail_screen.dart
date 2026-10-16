import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../models/product.dart';
import '../state/cart.dart';
import '../utils/formatters.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_image.dart';

/// Ürün detay sayfası. Ürün, route argümanı olarak gelir.
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  void _addToCart(BuildContext context) {
    final added = CartScope.of(context).add(product);
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text(
          added
              ? '${product.name} sepete eklendi.'
              : 'Stoktaki tüm ürünler zaten sepetinizde.',
        ),
        action: added
            ? SnackBarAction(
                label: 'Sepete git',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inCart = CartScope.of(context).quantityOf(product);

    // Sayfadan çıkarken açık kalan bildirimi kapat.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ürün Detayı'),
          actions: const [CartButton(), SizedBox(width: 8)],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Container(
              height: 280,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Hero(
                tag: 'product-${product.id}',
                child: ProductImage(url: product.image),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  '${product.brand} · ${product.category}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: Color(0xFFF5A524),
                ),
                const SizedBox(width: 2),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatPrice(product.price),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StockLabel(stock: product.stock),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Açıklama',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            if (product.features.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Öne Çıkan Özellikler',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final feature in product.features)
                    Chip(
                      avatar: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(feature),
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: product.inStock ? () => _addToCart(context) : null,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(
              !product.inStock
                  ? 'Stokta yok'
                  : inCart > 0
                  ? 'Sepete Ekle ($inCart adet sepette)'
                  : 'Sepete Ekle',
            ),
          ),
        ),
      ),
    );
  }
}

class _StockLabel extends StatelessWidget {
  final int stock;

  const _StockLabel({required this.stock});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (stock) {
      0 => ('Tükendi', Colors.red.shade700),
      < 10 => ('Son $stock ürün', Colors.orange.shade800),
      _ => ('Stokta', Colors.green.shade700),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
