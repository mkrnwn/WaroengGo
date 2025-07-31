import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Hapus Import ini

import 'package:waroeng_go1/shopping_cart_service.dart';
import 'package:waroeng_go1/firestore_service.dart';
import 'package:waroeng_go1/models.dart';
import 'package:waroeng_go1/order_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime _selectedPickupDate = DateTime.now();
  TimeOfDay _selectedPickupTime = TimeOfDay.now();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash; // Default: Cash
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _selectedPickupDate = DateTime.now();
    _selectedPickupTime = TimeOfDay.fromDateTime(
      DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedPickupDate) {
      setState(() {
        _selectedPickupDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedPickupTime,
    );
    if (picked != null && picked != _selectedPickupTime) {
      setState(() {
        _selectedPickupTime = picked;
      });
    }
  }

  void _placeOrder(
    BuildContext context,
    ShoppingCartService cartService,
  ) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda perlu login untuk memesan.')),
      );
      return;
    }

    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang belanja Anda kosong.')),
      );
      return;
    }

    DateTime pickupDateTime = DateTime(
      _selectedPickupDate.year,
      _selectedPickupDate.month,
      _selectedPickupDate.day,
      _selectedPickupTime.hour,
      _selectedPickupTime.minute,
    );

    if (pickupDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu pengambilan tidak boleh di masa lalu.'),
        ),
      );
      return;
    }

    final order = Order(
      id: '',
      userId: currentUser!.uid,
      items: cartService.items,
      totalAmount: cartService.totalAmount,
      orderTime: DateTime.now(),
      pickupTime: pickupDateTime,
      status: 'Pending',
      paymentMethod: _selectedPaymentMethod,
    );

    try {
      await _firestoreService.placeOrder(order);
      cartService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil ditempatkan!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OrderListScreen(isSellerView: false),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menempatkan pesanan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingCartService>(
      builder: (context, cartService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body:
              cartService.items.isEmpty
                  ? Center(
                    child: Text(
                      'Keranjang belanja Anda kosong.\nSilakan tambahkan makanan dari menu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item di Keranjang:',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartService.items.length,
                          itemBuilder: (context, index) {
                            final item = cartService.items[index];
                            return Card(
                              color:
                                  Theme.of(
                                    context,
                                  ).cardColor, // Menggunakan warna tema
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        // Kembali menggunakan Image.network
                                        item.imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                  width: 60,
                                                  height: 60,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.foodName,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${item.price.toStringAsFixed(0)}',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () {
                                            cartService.updateQuantity(
                                              item.foodItemId,
                                              item.quantity - 1,
                                            );
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () {
                                            // TODO: Validasi stok di sini agar tidak melebihi stok yang sebenarnya
                                            cartService.updateQuantity(
                                              item.foodItemId,
                                              item.quantity + 1,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                          ),
                                          onPressed: () {
                                            cartService.removeItem(
                                              item.foodItemId,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Total: Rp ${cartService.totalAmount.toStringAsFixed(0)}',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Waktu Pengambilan:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            '${DateFormat('dd MMMM yyyy').format(_selectedPickupDate)} at ${_selectedPickupTime.format(context)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () {
                            _selectDate(
                              context,
                            ).then((_) => _selectTime(context));
                          },
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Metode Pembayaran:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children:
                              PaymentMethod.values.map((method) {
                                return RadioListTile<PaymentMethod>(
                                  title: Text(
                                    method
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  value: method,
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (PaymentMethod? value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  },
                                  activeColor: Theme.of(context).primaryColor,
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _placeOrder(context, cartService),
                            child: const Text('Tempatkan Pesanan'),
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
