import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../api_service.dart';
import '../product.dart';
import '../shopping_cart.dart';
import 'checkout_page.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _showNotification = false;
  late Future<List<Product>> _productsFuture;
  final ApiService _apiService = ApiService();

  final String organizationId = '209125aceafd409da63981e3f490cc86'; // Replace with your actual organization ID when you find it
  final String appId = 'XFK83THSULFBKRJ'; // Replace with your actual APP ID
  final String apiKey = '119e6f592d1f45738b941e0b7c85ff2420240705093646438302'; // Replace with your actual API Key

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts(organizationId, appId, apiKey);
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) {
      return products;
    } else {
      return products.where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showCartNotification() {
    setState(() {
      _showNotification = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final products = _filterProducts(snapshot.data ?? []);
            return ProductGrid(
              products,
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onProductAdded: _showCartNotification,
              onProductRemoved: _showCartNotification, // Added callback for product removal
            );
          }
        },
      ),
      const CheckoutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: _selectedIndex == 0
            ? const Text(
                'Products',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              )
            : const Text(
                'Cart',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          screens[_selectedIndex],
          if (_showNotification)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'Cart successfully updated',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Consumer<ShoppingCart>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: <Widget>[
                    const Icon(Icons.shopping_cart),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                ),
                label: 'Checkout',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(String) onSearch;
  final VoidCallback onProductAdded;
  final VoidCallback onProductRemoved;

  const ProductGrid(
    this.products, {
    super.key,
    required this.onSearch,
    required this.onProductAdded,
    required this.onProductRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ShoppingCart>(context);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search Products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onChanged: onSearch,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              final product = products[index];
              final productInCart = cart.items.firstWhere(
                (item) => item.id == product.id,
                orElse: () => Product(id: '', name: '', imageUrl: '', price: 0),
              );
              return GridTile(
                child: Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display product image
                      Container(
                        height: 150,
                        width: double.infinity,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '₦${formatter.format(product.price)}',
                              style: const TextStyle(fontSize: 14, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: productInCart.quantity == 0
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    cart.addProduct(product);
                                    onProductAdded();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      cart.removeProduct(product);
                                      onProductRemoved();
                                    },
                                  ),
                                  Text(productInCart.quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      cart.addProduct(product);
                                      onProductAdded();
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
