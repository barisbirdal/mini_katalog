import 'package:flutter/material.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'state/cart.dart';

void main() {
  runApp(MiniKatalogApp(cart: Cart()));
}

class MiniKatalogApp extends StatelessWidget {
  final Cart cart;

  const MiniKatalogApp({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    // Sepet, tüm sayfalardan erişilebilmesi için MaterialApp'in üstünde tutulur.
    return CartScope(
      cart: cart,
      child: MaterialApp(
        title: 'Mini Katalog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
