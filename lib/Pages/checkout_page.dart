import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Import the main file to access ShoppingCart class
import 'order_success.dart'; // Import the order success page

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ShoppingCart>(context);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      body: Column(
        children: [
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CART SUMMARY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('₦${formatter.format(cart.totalPrice)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          if (cart.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'CART (${cart.itemCount})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          Expanded(
            child: cart.items.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return Dismissible(
                        key: Key(product.name),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          cart.removeProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${product.name} removed from cart")),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Seller: Brand name',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Size/Color',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '₦${formatter.format(product.price)}',
                                          style: const TextStyle(fontSize: 14, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          cart.addProduct(product);
                                        },
                                      ),
                                      Text(product.quantity.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          cart.removeProduct(product);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text('Your cart is empty.'),
                  ),
          ),
          if (cart.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderSuccessPage()),
                    ).then((value) => cart.clearCart());
                  },
                  child: Text('Checkout (₦${formatter.format(cart.totalPrice)})', style: const TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
