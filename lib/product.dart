class Product {
  final String id;
  final String name;
  final List<String> imageUrls; // Change this to a list of URLs
  final double price;
  int quantity;
  final int availableQuantity;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.imageUrls, // Change constructor parameter
    required this.price,
    this.quantity = 1,
    required this.availableQuantity,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    const String imageBaseUrl = 'https://api.timbu.cloud/images/';
    List<String> imageUrls = [];
    if (json['photos'] != null && json['photos'].isNotEmpty) {
      for (var photo in json['photos']) {
        imageUrls.add(imageBaseUrl + photo['url']);
      }
    }

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrls: imageUrls, // Change this to handle list of URLs
      price: (json['current_price'] != null && json['current_price'].isNotEmpty && json['current_price'][0]['NGN'] != null)
          ? json['current_price'][0]['NGN'][0].toDouble()
          : 0.0,
      availableQuantity: json['available_quantity'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}
