import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/home_page.dart';

// Define product model (replace with your data structure)
class Product {
  final String name;
  final double price;
  int quantity;

  Product({required this.name, required this.price, this.quantity = 1});
}

// Shopping Cart class to manage selected items
class ShoppingCart extends ChangeNotifier {
  final List<Product> _items = [];

  void addProduct(Product product) {
    final existingIndex = _items.indexWhere((item) => item.name == product.name);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(Product(name: product.name, price: product.price, quantity: 1));
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    final index = _items.indexWhere((item) => item.name == product.name);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  List<Product> get items => _items;

  double get totalPrice => _items.fold(0.0, (sum, product) => sum + product.price * product.quantity);

  int get itemCount => _items.fold(0, (sum, product) => sum + product.quantity);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingCart(),
      child: MaterialApp(
        title: 'Shopping App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
