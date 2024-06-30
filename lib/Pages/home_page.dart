import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import the main file to access Product and ShoppingCart classes
import 'checkout_page.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _searchQuery = '';
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      ProductGrid(_filteredProducts, onSearch: (query) {
        setState(() {
          _searchQuery = query;
        });
      }),
      CheckoutPage(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color(0xFF808080), // Changed to shade of grey
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  _selectedIndex == 0 ? 'Products' : 'Cart',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Consumer<ShoppingCart>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.shopping_cart),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 15,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
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

  ProductGrid(this.products, {required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ShoppingCart>(context);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              final product = products[index];
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
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '₦${formatter.format(product.price)}',
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => cart.removeProduct(product),
                            ),
                            Consumer<ShoppingCart>(
                              builder: (context, cart, child) {
                                final productInCart = cart.items.firstWhere(
                                  (item) => item.name == product.name,
                                  orElse: () => Product(name: '', price: 0, quantity: 0),
                                );
                                return Text(productInCart.quantity.toString());
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => cart.addProduct(product),
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
