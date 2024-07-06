import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart'; // Import the Product model

class ApiService {
  final String _baseUrl = 'https://api.timbu.cloud/products'; // Base URL for the API

  Future<List<Product>> fetchProducts(String organizationId, String appId, String apiKey, {int page = 1, int size = 10, bool reverseSort = false}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?organization_id=$organizationId&reverse_sort=$reverseSort&page=$page&size=$size&Appid=$appId&Apikey=$apiKey'),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('JSON Response: $jsonResponse');
      if (jsonResponse.containsKey('items') && jsonResponse['items'] != null) {
        List<dynamic> items = jsonResponse['items'];
        return items.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product?> fetchProductById(String productId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$productId'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.isNotEmpty) {
        return Product.fromJson(jsonResponse);
      }
    }
    return null;
  }
}
