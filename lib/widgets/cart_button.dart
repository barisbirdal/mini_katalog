import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../state/cart.dart';

/// AppBar'da sepetteki ürün sayısını rozetle gösteren buton.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = CartScope.of(context).totalCount;

    return IconButton(
      tooltip: 'Sepet',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pushNamed(context, AppRoutes.cart);
      },
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
