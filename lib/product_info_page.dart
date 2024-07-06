import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../product.dart';

class ProductInfoPage extends StatelessWidget {
  final Product product;

  const ProductInfoPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enlarged product image
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₦${formatter.format(product.price)}',
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 20),
                      SizedBox(width: 5),
                      Text('4.5'),
                      SizedBox(width: 10),
                      Text('+3 colors', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select color',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildColorOption(Colors.blue),
                      _buildColorOption(Colors.green),
                      _buildColorOption(Colors.orange),
                      _buildColorOption(Colors.purple),
                      _buildColorOption(Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select quantity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuantityButton(Icons.remove),
                      const SizedBox(width: 10),
                      const Text('01', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      _buildQuantityButton(Icons.add),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add to cart functionality
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Background color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }
}
