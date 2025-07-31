// lib/order_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waroeng_go1/firestore_service.dart';
import 'package:waroeng_go1/models.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool
  isSellerView; // Untuk menentukan apakah menampilkan opsi update status

  const OrderCard({super.key, required this.order, this.isSellerView = false});

  // Fungsi helper untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Ready for Pickup':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    // Opsi status yang bisa dipilih penjual
    final List<String> statusOptions = [
      'Pending',
      'Confirmed',
      'Ready for Pickup',
      'Completed',
      'Cancelled',
    ];

    return Card(
      color: Theme.of(context).cardColor, // Menggunakan warna tema
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Waktu Pesan: ${DateFormat('dd MMM yyyy, HH:mm').format(order.orderTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Waktu Ambil: ${DateFormat('dd MMM yyyy, HH:mm').format(order.pickupTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Metode Pembayaran: ${order.paymentMethod.toString().split('.').last.toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Item Pesanan:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...order.items
                .map(
                  (item) => Text(
                    '${item.quantity}x ${item.foodName} @ Rp ${item.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
                .toList(),
            const SizedBox(height: 8),
            Text(
              'Total: Rp ${order.totalAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${order.status}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(order.status),
                  ),
                ),
                if (isSellerView)
                  DropdownButton<String>(
                    value: order.status,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _firestoreService.updateOrderStatus(order.id, newValue);
                      }
                    },
                    items:
                        statusOptions.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    dropdownColor:
                        Theme.of(
                          context,
                        ).cardColor, // Warna dropdown sesuai tema
                    style:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium, // Warna teks dropdown
                    iconEnabledColor:
                        Theme.of(
                          context,
                        ).iconTheme.color, // Warna ikon dropdown
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
