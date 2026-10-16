import 'package:flutter/widgets.dart';

import '../models/product.dart';

/// Sepetteki bir satır: ürün ve adedi.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

/// Basit sepet durumu (simülasyon).
///
/// Ekstra paket kullanmadan Flutter'ın kendi [ChangeNotifier] sınıfıyla
/// tutulur; değiştiğinde dinleyen widget'lar yeniden çizilir.
class Cart extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);

  bool get isEmpty => _items.isEmpty;

  int get totalCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.total);

  int quantityOf(Product product) => _items[product.id]?.quantity ?? 0;

  /// Ürünü sepete ekler. Stok sınırına ulaşıldıysa `false` döner.
  bool add(Product product) {
    final current = quantityOf(product);
    if (current >= product.stock) return false;

    _items.update(
      product.id,
      (item) => item..quantity += 1,
      ifAbsent: () => CartItem(product: product),
    );
    notifyListeners();
    return true;
  }

  /// Ürünün adedini bir azaltır; adet sıfıra inerse sepetten çıkarır.
  void decrement(Product product) {
    final item = _items[product.id];
    if (item == null) return;

    if (item.quantity > 1) {
      item.quantity -= 1;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void remove(Product product) {
    if (_items.remove(product.id) != null) notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// [Cart] nesnesini widget ağacının altına taşıyan InheritedNotifier.
///
/// `CartScope.of(context)` çağıran widget'lar sepet değiştiğinde
/// otomatik olarak yeniden çizilir.
class CartScope extends InheritedNotifier<Cart> {
  const CartScope({super.key, required Cart cart, required super.child})
    : super(notifier: cart);

  static Cart of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CartScope>();
    assert(scope != null, 'Widget ağacında CartScope bulunamadı.');
    return scope!.notifier!;
  }
}
