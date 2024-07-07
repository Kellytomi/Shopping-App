import 'package:flutter/material.dart';
import '../Models/product.dart';

class ShoppingCart extends ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;

  double get totalPrice => _items.fold(0, (total, current) => total + current.price * current.quantity);

  int get itemCount => _items.fold(0, (total, current) => total + current.quantity);

  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(product..quantity = 1);
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
    }
    notifyListeners();
  }

  void removeAllOfProduct(Product product) {
    _items.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
