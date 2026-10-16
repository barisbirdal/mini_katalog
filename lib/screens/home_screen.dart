import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner.dart';

/// Ana sayfa: banner, arama, kategori filtresi ve ürün grid'i.
class HomeScreen extends StatefulWidget {
  final ProductRepository? repository;

  const HomeScreen({super.key, this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _allCategories = 'Tümü';

  late final ProductRepository _repository;
  late Future<List<Product>> _productsFuture;

  String _query = '';
  String _selectedCategory = _allCategories;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProductRepository();
    _productsFuture = _repository.fetchProducts();
  }

  void _reload() {
    setState(() => _productsFuture = _repository.fetchProducts());
  }

  List<String> _categoriesOf(List<Product> products) {
    final categories = products.map((p) => p.category).toSet().toList();
    return [_allCategories, ...categories];
  }

  List<Product> _filter(List<Product> products) {
    final query = _query.trim().toLowerCase();

    return products.where((p) {
      final matchesCategory =
          _selectedCategory == _allCategories ||
          p.category == _selectedCategory;
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openDetail(Product product) {
    // Ürün, Route Arguments ile detay sayfasına taşınır.
    Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Katalog'),
        actions: const [CartButton(), SizedBox(width: 8)],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: _reload);
          }

          final products = snapshot.data ?? [];
          return _buildContent(products);
        },
      ),
    );
  }

  Widget _buildContent(List<Product> products) {
    final categories = _categoriesOf(products);
    final visible = _filter(products);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
          sliver: SliverToBoxAdapter(child: PromoBanner()),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Ürün veya marka ara',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: category == _selectedCategory,
                  showCheckmark: false,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${visible.length} ürün',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        if (visible.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyView())
        else
          // Ürün kartları grid yapısında (GridView'in sliver karşılığı) listelenir.
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid.builder(
              itemCount: visible.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = visible[index];
                return ProductCard(
                  product: product,
                  onTap: () => _openDetail(product),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: color),
          const SizedBox(height: 12),
          Text(
            'Aramanızla eşleşen ürün bulunamadı.',
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ürünler yüklenemedi.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
