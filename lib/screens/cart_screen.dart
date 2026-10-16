import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../state/cart.dart';
import '../utils/formatters.dart';
import '../widgets/product_image.dart';

/// Sepet sayfası (simülasyon): adet güncelleme, silme ve toplam tutar.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, Cart cart) async {
    final total = formatPrice(cart.totalPrice);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Siparişiniz alındı'),
        content: Text(
          '$total tutarındaki siparişiniz oluşturuldu.\n'
          '(Bu bir simülasyondur, gerçek ödeme alınmaz.)',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );

    cart.clear();
    // Sipariş sonrası doğrudan ana sayfaya dönülür.
    if (context.mounted) {
      Navigator.popUntil(context, ModalRoute.withName(AppRoutes.home));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
        actions: [
          if (!cart.isEmpty)
            TextButton(onPressed: cart.clear, child: const Text('Temizle')),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _CartRow(item: cart.items[index], cart: cart),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Toplam (${cart.totalCount} ürün)',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        formatPrice(cart.totalPrice),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _checkout(context, cart),
                    child: const Text('Siparişi Tamamla'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final Cart cart;

  const _CartRow({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ProductImage(url: product.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(item.total),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _QuantityStepper(
              quantity: item.quantity,
              onDecrement: () => cart.decrement(product),
              onIncrement: item.quantity < product.stock
                  ? () => cart.add(product)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback? onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Azalt',
            icon: Icon(quantity > 1 ? Icons.remove : Icons.delete_outline),
            onPressed: onDecrement,
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Arttır',
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: color),
          const SizedBox(height: 12),
          Text('Sepetiniz boş', style: TextStyle(color: color, fontSize: 16)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Alışverişe devam et'),
          ),
        ],
      ),
    );
  }
}
