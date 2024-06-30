import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Import to access ShoppingCart class
import 'home_page.dart'; // Import the home page

class OrderSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ShoppingCart>(context, listen: false);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Adjusted top padding
            Icon(
              Icons.check_circle,
              color: Colors.blue,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Great!',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              'Order Success',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Below is your order summary',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final product = cart.items[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 30, color: Colors.grey),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '₦${formatter.format(product.price)} x ${product.quantity}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '₦${formatter.format(product.price * product.quantity)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total Order',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 5),
            Text(
              '₦${formatter.format(cart.totalPrice)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 40), // Increased the height here to bring up the elements
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Back to home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 20), // Added bottom padding to move the button up a bit
          ],
        ),
      ),
    );
  }
}
