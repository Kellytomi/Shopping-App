import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/home_page.dart';
import 'product.dart';
import 'shopping_cart.dart';
import 'api_service.dart';

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
