// lib/order_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waroeng_go1/firestore_service.dart';
import 'package:waroeng_go1/models.dart';
import 'package:waroeng_go1/order_card.dart';

class OrderListScreen extends StatelessWidget {
  final bool isSellerView;
  const OrderListScreen({super.key, this.isSellerView = false});

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    Stream<List<Order>> orderStream;
    if (isSellerView) {
      orderStream = _firestoreService.getAllOrders();
    } else {
      if (currentUser == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pesanan Saya'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          body: Center(
            child: Text(
              'Anda perlu login untuk melihat pesanan.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      }
      orderStream = _firestoreService.getOrdersForUser(currentUser.uid);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isSellerView ? 'Semua Pesanan Penjual' : 'Pesanan Saya'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: StreamBuilder<List<Order>>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                isSellerView
                    ? 'Belum ada pesanan masuk.'
                    : 'Anda belum memiliki pesanan.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order, isSellerView: isSellerView);
            },
          );
        },
      ),
    );
  }
}
