import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product.dart';

/// Ürün verisini sağlayan sınıf.
///
/// Gerçek bir API yerine `assets/data/products.json` dosyası okunarak
/// bir API cevabı simüle edilir.
class ProductRepository {
  static const String _assetPath = 'assets/data/products.json';

  final AssetBundle _bundle;

  ProductRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Future<List<Product>> fetchProducts() async {
    // Ağ gecikmesini simüle etmek için kısa bir bekleme.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final raw = await _bundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['products'] as List<dynamic>;

    return list
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
