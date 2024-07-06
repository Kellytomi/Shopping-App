import 'package:flutter/material.dart';
import 'product.dart';

class ShoppingCart extends ChangeNotifier {
  final List<Product> _items = [];

  void addProduct(Product product) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity < product.availableQuantity) {
        _items[existingIndex].quantity++;
      }
    } else {
      _items.add(product);
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);
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
