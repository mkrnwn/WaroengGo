// lib/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waroeng_go1/shopping_cart_service.dart';
import 'package:waroeng_go1/models.dart';
import 'package:intl/intl.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantity = 1;
  }

  void _addToCart() async {
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuantitas harus lebih dari 0.')),
      );
      return;
    }

    if (_quantity > widget.foodItem.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuantitas melebihi stok yang tersedia.')),
      );
      return;
    }

    Provider.of<ShoppingCartService>(
      context,
      listen: false,
    ).addItem(widget.foodItem, _quantity);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_quantity}x ${widget.foodItem.name} ditambahkan ke keranjang!',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Makanan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: 'foodImage-${widget.foodItem.id}',
              child: Image.network(
                widget.foodItem.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      height: 250,
                      width: double.infinity,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.foodItem.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${widget.foodItem.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.foodItem.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.foodItem.stock > 0
                        ? 'Stok Tersedia: ${widget.foodItem.stock}'
                        : 'Stok Habis',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          widget.foodItem.stock > 0
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kuantitas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor, // Menggunakan warna tema
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_quantity > 1) _quantity--;
                                });
                              },
                            ),
                            Text(
                              '$_quantity',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_quantity < widget.foodItem.stock)
                                    _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.foodItem.stock > 0 ? _addToCart : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(
                        widget.foodItem.stock > 0
                            ? 'Tambahkan ke Keranjang'
                            : 'Stok Habis',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
