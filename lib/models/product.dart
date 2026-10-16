/// Katalogdaki tek bir ürünü temsil eden model sınıfı.
///
/// Veri, `assets/data/products.json` dosyasından okunur ve
/// [Product.fromJson] ile nesneye dönüştürülür.
class Product {
  final int id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String image;
  final String description;
  final List<String> features;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.image,
    required this.description,
    this.features = const [],
  });

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      // JSON'da sayılar int ya da double gelebilir; num üzerinden dönüştürülür.
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      stock: json['stock'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'rating': rating,
      'stock': stock,
      'image': image,
      'description': description,
      'features': features,
    };
  }
}
