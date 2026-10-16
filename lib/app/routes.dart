import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

/// Uygulamadaki named route isimleri.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String productDetail = '/product';
  static const String cart = '/cart';

  /// Route Arguments ile veri taşıyan sayfalar için route üretici.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case productDetail:
        // Detay sayfası, gösterilecek ürünü argüman olarak alır.
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
          settings: settings,
        );
      case cart:
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
          settings: settings,
        );
    }
    return null;
  }
}
