import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import the main file to access Product and ShoppingCart classes
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
  final List<Product> _products = [
    Product(name: 'Shirt', price: 25000.00), // Price in NGN
    Product(name: 'Pants', price: 30000.00), // Price in NGN
    Product(name: 'Shoes', price: 52500.00), // Price in NGN
  ];

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _products;
    } else {
      return _products.where((product) => product.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
    Future.delayed(const Duration(seconds: 1), () { // Reduced duration to 1 second
      setState(() {
        _showNotification = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProductGrid(
        _filteredProducts,
        onSearch: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        onProductAdded: _showCartNotification,
        onProductRemoved: _showCartNotification, // Added callback for product removal
      ),
      const CheckoutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey, // Updated app bar color
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
                              fontSize: 10, // Adjusted size to be readable but not too big
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

// Product Grid with quantity control and search functionality
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
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              final product = products[index];
              final productInCart = cart.items.firstWhere(
                (item) => item.name == product.name,
                orElse: () => Product(name: '', price: 0, quantity: 0),
              );
              return GridTile(
                child: Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder for product image
                      Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: productInCart.quantity == 0
                              ? SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      cart.addProduct(product);
                                      onProductAdded();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange, // Changed button color to orange
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
                                        if (productInCart.quantity > 1) {
                                          cart.removeProduct(product);
                                        } else {
                                          cart.removeProduct(product);
                                        }
                                        onProductRemoved(); // Show notification on remove
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
