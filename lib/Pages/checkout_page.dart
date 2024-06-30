import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Import the main file to access ShoppingCart class
import 'order_success.dart'; // Import the order success page

class CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ShoppingCart>(context);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      body: Column(
        children: [
          if (cart.items.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CART SUMMARY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: TextStyle(fontSize: 16)),
                      Text('₦${formatter.format(cart.totalPrice)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Expanded(
            child: cart.items.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.only(top: 8.0),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return Dismissible(
                        key: Key(product.name),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          cart.items.removeAt(index);
                          cart.notifyListeners();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${product.name} removed from cart")),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
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
                                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Seller: Brand name',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Size/Color',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '₦${formatter.format(product.price)}',
                                          style: TextStyle(fontSize: 14, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          cart.addProduct(product);
                                        },
                                      ),
                                      Text(product.quantity.toString()),
                                      IconButton(
                                        icon: Icon(Icons.remove),
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
                : Center(
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
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderSuccessPage()),
                    ).then((value) => cart.clearCart());
                  },
                  child: Text('Checkout (₦${formatter.format(cart.totalPrice)})'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
