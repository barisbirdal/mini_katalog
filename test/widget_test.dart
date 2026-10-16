import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_katalog/main.dart';
import 'package:mini_katalog/models/product.dart';
import 'package:mini_katalog/state/cart.dart';
import 'package:mini_katalog/utils/formatters.dart';

const _sample = Product(
  id: 1,
  name: 'Test Telefon',
  brand: 'Marka',
  category: 'Telefon',
  price: 1500,
  rating: 4.5,
  stock: 2,
  image: '',
  description: 'Açıklama',
  features: ['A', 'B'],
);

void main() {
  group('Product', () {
    test('fromJson / toJson veriyi korur', () {
      final json = _sample.toJson();
      final parsed = Product.fromJson(json);

      expect(parsed.toJson(), json);
      expect(parsed.features, ['A', 'B']);
    });

    test('fromJson int fiyatı double\'a çevirir', () {
      final p = Product.fromJson({'id': 2, 'name': 'X', 'price': 10});
      expect(p.price, 10.0);
      expect(p.inStock, isFalse);
    });
  });

  group('Cart', () {
    test('stok sınırına kadar ekler ve toplamı hesaplar', () {
      final cart = Cart();

      expect(cart.add(_sample), isTrue);
      expect(cart.add(_sample), isTrue);
      expect(cart.add(_sample), isFalse); // stok: 2
      expect(cart.totalCount, 2);
      expect(cart.totalPrice, 3000);

      cart.decrement(_sample);
      cart.decrement(_sample);
      expect(cart.isEmpty, isTrue);
    });
  });

  test('formatPrice Türkçe biçim kullanır', () {
    expect(formatPrice(54999), '₺54.999,00');
    expect(formatPrice(999.5), '₺999,50');
    expect(formatPrice(1234567.891), '₺1.234.567,89');
  });

  testWidgets('ana sayfa → detay → sepet akışı', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cart = Cart();
    await tester.pumpWidget(MiniKatalogApp(cart: cart));

    // Ürünler JSON asset'ten yüklenir.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pumpAndSettle();
    expect(find.text('16 ürün'), findsOneWidget);

    // Arama filtresi.
    await tester.enterText(find.byType(TextField), 'macbook');
    await tester.pump();
    expect(find.text('1 ürün'), findsOneWidget);

    // Detay sayfasına geçiş (Route Arguments).
    await tester.tap(find.text('MacBook Pro 14"'));
    await tester.pumpAndSettle();
    expect(find.text('Ürün Detayı'), findsOneWidget);

    await tester.tap(find.text('Sepete Ekle'));
    await tester.pump();
    expect(cart.totalCount, 1);

    // Sepet sayfası.
    await tester.tap(find.byTooltip('Sepet'));
    await tester.pumpAndSettle();
    expect(find.text('Sepetim'), findsOneWidget);
    expect(find.text('Toplam (1 ürün)'), findsOneWidget);
  });
}
