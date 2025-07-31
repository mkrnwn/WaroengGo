// lib/manage_products_screen.dart
import 'package:flutter/material.dart';
import 'package:waroeng_go1/firestore_service.dart';
import 'package:waroeng_go1/models.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Hapus Import ini jika tidak dipakai

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory =
      'Lainnya'; // State untuk kategori yang dipilih (dari implementasi kategori)

  FoodItem? _selectedFoodItem;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _showAddEditDialog({FoodItem? item}) {
    _selectedFoodItem = item;
    if (item != null) {
      _nameController.text = item.name;
      _descriptionController.text = item.description;
      _priceController.text = item.price.toString();
      _stockController.text = item.stock.toString();
      _imageUrlController.text = item.imageUrl;
      _selectedCategory = item.category; // Set kategori saat edit
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
      _imageUrlController.clear();
      _selectedCategory = 'Lainnya'; // Default kategori saat tambah baru
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            item == null ? 'Tambah Produk Baru' : 'Edit Produk',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Makanan'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL Gambar'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      <String>[
                        'Nasi',
                        'Mie',
                        'Minuman',
                        'Snack',
                        'Lainnya',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        // setState ini hanya berpengaruh di dialog
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = _nameController.text;
                final String description = _descriptionController.text;
                final double price =
                    double.tryParse(_priceController.text) ?? 0.0;
                final int stock = int.tryParse(_stockController.text) ?? 0;
                final String imageUrl =
                    _imageUrlController.text.isEmpty
                        ? 'https://via.placeholder.com/150'
                        : _imageUrlController.text;

                if (name.isEmpty ||
                    price <= 0 ||
                    stock < 0 ||
                    imageUrl.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Harap lengkapi semua data dengan benar.',
                        ),
                      ),
                    );
                  }
                  return;
                }

                final FoodItem newOrUpdatedItem = FoodItem(
                  id: item?.id ?? '',
                  name: name,
                  description: description,
                  price: price,
                  stock: stock,
                  imageUrl: imageUrl,
                  category: _selectedCategory,
                );

                try {
                  if (item == null) {
                    await _firestoreService.addFoodItem(newOrUpdatedItem);
                  } else {
                    await _firestoreService.updateFoodItem(newOrUpdatedItem);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item == null ? 'Produk berhasil ditambahkan' : 'Produk berhasil diperbarui'}',
                        ),
                      ),
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan produk: $e')),
                    );
                  }
                }
              },
              child: Text(item == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(String itemId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestoreService.deleteFoodItem(itemId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk berhasil dihapus')),
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus produk: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: _firestoreService.getFoodItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada menu yang ditambahkan. Tekan tombol + untuk menambah.',
              ),
            );
          }

          final foodItems = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final item = foodItems[index];
              return Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          item.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                width: 70,
                                height: 70,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${item.price.toStringAsFixed(0)}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.stock > 0
                                  ? 'Stok: ${item.stock}'
                                  : 'Stok Habis',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    item.stock > 0
                                        ? Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () => _showAddEditDialog(item: item),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _confirmDelete(item.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // <--- PASTIKAN BLOK INI ADA DI DALAM SCAFFOLD
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
