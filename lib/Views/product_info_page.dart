import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../Models/product.dart';
import 'package:provider/provider.dart';
import '../Provider/shopping_cart.dart';

class ProductInfoPage extends StatefulWidget {
  final Product product;

  const ProductInfoPage({super.key, required this.product});

  @override
  _ProductInfoPageState createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  bool _showNotification = false;

  void _showNotificationBar() {
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
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final cart = Provider.of<ShoppingCart>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.white, // Set background color to white
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carousel for product images
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: false,
                      enlargeCenterPage: true,
                    ),
                    items: widget.product.imageUrls.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₦${formatter.format(widget.product.price)}',
                          style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 48), // Increased extra space to push content above
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20, // Add a margin to raise it up
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[200], // Very light grey color
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cart.items.any((item) => item.id == widget.product.id))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.orange,
                          onPressed: () {
                            cart.removeProduct(widget.product);
                            _showNotificationBar();
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            cart.items.firstWhere((item) => item.id == widget.product.id).quantity.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.orange,
                          onPressed: () {
                            cart.addProduct(widget.product);
                            _showNotificationBar();
                          },
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          cart.addProduct(widget.product);
                          _showNotificationBar();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_showNotification)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.green,
                padding: const EdgeInsets.all(16.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Cart successfully updated',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
