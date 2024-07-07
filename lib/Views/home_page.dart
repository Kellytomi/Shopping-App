import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shopping_cart/Views/Widgets/error_widget.dart';
import 'package:badges/badges.dart' as badges;
import '../Services/api_service.dart';
import '../Models/product.dart';
import '../Provider/shopping_cart.dart';
import 'checkout_page.dart';
import 'package:shopping_cart/Views/product_info_page.dart';
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

  final String organizationId = '209125aceafd409da63981e3f490cc86';
  final String appId = 'XFK83THSULFBKRJ';
  final String apiKey = '119e6f592d1f45738b941e0b7c85ff2420240705093646438302';

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.fetchProducts(organizationId, appId, apiKey);
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _apiService.fetchProducts(organizationId, appId, apiKey);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshProducts();
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
      RefreshIndicator(
        onRefresh: _refreshProducts,
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 20.0,
                  color: Colors.orange,
                ),
              );
            } else if (snapshot.hasError) {
              return ErrorWidgetCustom(
                message: 'Slow or no internet connections. Please check your internet settings',
                onRetry: _refreshProducts,
              );
            } else {
              final products = _filterProducts(snapshot.data ?? []);
              return ProductGrid(
                products: products,
                onSearch: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onProductAdded: _showCartNotification,
                onProductRemoved: _showCartNotification,
              );
            }
          },
        ),
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
                    badges.Badge(
                      badgeContent: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      showBadge: cart.itemCount > 0,
                      child: const Icon(Icons.shopping_cart),
                    ),
                  ],
                ),
                label: 'Checkout',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          );
        },
      ),
    );
  }
}

class ProductGrid extends StatefulWidget {
  final List<Product> products;
  final Function(String) onSearch;
  final VoidCallback onProductAdded;
  final VoidCallback onProductRemoved;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onSearch,
    required this.onProductAdded,
    required this.onProductRemoved,
  });

  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final Map<String, bool> _showQuantityButtons = {};

  void _toggleQuantityButtons(String productId) {
    setState(() {
      _showQuantityButtons[productId] = !(_showQuantityButtons[productId] ?? false);
    });
  }

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
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            onChanged: widget.onSearch,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: widget.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, index) {
              final product = widget.products[index];
              final productInCart = cart.items.firstWhere(
                (item) => item.id == product.id,
                orElse: () => Product(id: '', name: '', imageUrls: [], price: 0, availableQuantity: 0, description: ''),
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductInfoPage(product: product),
                    ),
                  );
                },
                child: GridTile(
                  child: Card(
                    elevation: 5,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                          child: SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: Image.network(
                              product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
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
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '₦${formatter.format(product.price)}',
                                style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          child: Column(
                            children: [
                              if (cart.items.any((item) => item.id == product.id))
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (productInCart.quantity > 1) {
                                          cart.removeProduct(product);
                                          widget.onProductRemoved();
                                        } else {
                                          cart.removeProduct(product);
                                          widget.onProductRemoved();
                                          _toggleQuantityButtons(product.id);
                                        }
                                      },
                                    ),
                                    Text(productInCart.quantity.toString()),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        if (productInCart.quantity < product.availableQuantity) {
                                          cart.addProduct(product);
                                          widget.onProductAdded();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Out of Stock"),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: product.availableQuantity > 0
                                        ? () {
                                            cart.addProduct(product);
                                            widget.onProductAdded();
                                            _toggleQuantityButtons(product.id);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: product.availableQuantity > 0 ? Colors.orange : Colors.grey,
                                    ),
                                    child: Text(
                                      product.availableQuantity > 0 ? 'Add to Cart' : 'Out of Stock',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
