class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    const String imageBaseUrl = 'https://api.timbu.cloud/images/';
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['photos'] != null && json['photos'].isNotEmpty
          ? imageBaseUrl + json['photos'][0]['url']
          : '',
      price: (json['current_price'] != null && json['current_price'].isNotEmpty && json['current_price'][0]['NGN'] != null)
          ? json['current_price'][0]['NGN'][0].toDouble()
          : 0.0,
    );
  }
}
