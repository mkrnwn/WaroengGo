// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waroeng_go1/auth_service.dart';
import 'package:waroeng_go1/firestore_service.dart';
import 'package:waroeng_go1/models.dart';

import 'package:waroeng_go1/food_detail_screen.dart';
import 'package:waroeng_go1/order_list_screen.dart';
import 'package:waroeng_go1/manage_products_screen.dart';
import 'package:waroeng_go1/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:waroeng_go1/shopping_cart_service.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Hapus Import ini

import 'package:waroeng_go1/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isSellerMode = false;
  String _selectedCategory = 'Semua'; // State untuk kategori yang dipilih

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WaroengGO'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isSellerMode ? Icons.shopping_cart : Icons.store),
            tooltip:
                _isSellerMode
                    ? 'Beralih ke Mode Pembeli'
                    : 'Beralih ke Mode Penjual',
            onPressed: () {
              setState(() {
                _isSellerMode = !_isSellerMode;
              });
            },
          ),
          if (!_isSellerMode)
            Consumer<ShoppingCartService>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      tooltip: 'Keranjang Belanja',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                    ),
                    if (cart.totalItemsCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.totalItemsCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout dari aplikasi',
            onPressed: () async {
              await _auth.signOut();
              Provider.of<ShoppingCartService>(
                context,
                listen: false,
              ).clearCart();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'WaroengGO Navigation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.food_bank,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Menu Makanan (Pembeli)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isSellerMode = false;
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_bag,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Pesanan Saya (Pembeli)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const OrderListScreen(isSellerView: false),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.store,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Kelola Produk (Penjual)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isSellerMode = true;
                });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.list_alt,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Semua Pesanan (Penjual)',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const OrderListScreen(isSellerView: true),
                  ),
                );
              },
            ),
            const Divider(),
            // TOMBOL DARK MODE
            ListTile(
              leading: Icon(
                themeService.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                themeService.themeMode == ThemeMode.dark
                    ? 'Mode Terang'
                    : 'Mode Gelap',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Switch(
                value: themeService.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeService.toggleTheme();
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              onTap: () {
                // Tidak perlu pop drawer jika switch ada di trailing
              },
            ),
          ],
        ),
      ),
      body: _isSellerMode ? _buildSellerView() : _buildBuyerView(),
    );
  }

  // Tampilan untuk Pembeli
  Widget _buildBuyerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: Text(
            'Kategori Pilihan',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              _buildCategoryCard(
                'Semua',
                Icons.category,
                Colors.grey,
              ), // Tambahkan kategori 'Semua'
              _buildCategoryCard('Nasi', Icons.rice_bowl, Colors.orange),
              _buildCategoryCard('Mie', Icons.ramen_dining, Colors.blue),
              _buildCategoryCard('Minuman', Icons.local_drink, Colors.teal),
              _buildCategoryCard('Snack', Icons.cookie, Colors.purple),
              _buildCategoryCard('Lainnya', Icons.more_horiz, Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Menu Harian & Populer',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<FoodItem>>(
            stream: _firestoreService.getFoodItems(
              category: _selectedCategory,
            ), // TERPENGARUH OLEH KATEGORI
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error saat memuat menu: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Belum ada menu makanan yang tersedia.'),
                );
              }

              final foodItems = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return _buildFoodItemCard(context, item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget untuk kartu kategori
  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    bool isSelected = _selectedCategory == title;
    return GestureDetector(
      // Agar kartu bisa diklik
      onTap: () {
        setState(() {
          _selectedCategory = title; // Set kategori yang dipilih
        });
      },
      child: Card(
        color:
            isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Theme.of(context).cardColor, // Warna berubah jika terpilih
        elevation: isSelected ? 8 : 4, // Elevasi berubah jika terpilih
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? Theme.of(context).primaryColor : color,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk kartu item makanan
  Widget _buildFoodItemCard(BuildContext context, FoodItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(foodItem: item),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'foodImage-${item.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    item.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.broken_image,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${item.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.stock > 0 ? 'Stok: ${item.stock}' : 'Stok Habis',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            item.stock > 0
                                ? Theme.of(context).textTheme.bodySmall?.color
                                : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child:
                    item.stock > 0
                        ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            onPressed: () {
                              Provider.of<ShoppingCartService>(
                                context,
                                listen: false,
                              ).addItem(item, 1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item.name} ditambahkan ke keranjang!',
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerView() {
    return const ManageProductsScreen();
  }
}
