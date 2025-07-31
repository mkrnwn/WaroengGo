// lib/models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum untuk metode pembayaran
enum PaymentMethod { cash, dana, gopay }

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category; // TAMBAHKAN INI

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category, // TAMBAHKAN INI
  });

  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FoodItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
      category:
          data['category'] ?? 'Lainnya', // TAMBAHKAN INI, default 'Lainnya'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'category': category, // TAMBAHKAN INI
    };
  }
}

class OrderItem {
  final String foodItemId;
  final String foodName;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.foodItemId,
    required this.foodName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItemId,
      'foodName': foodName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      foodItemId: map['foodItemId'],
      foodName: map['foodName'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderTime;
  final DateTime pickupTime;
  String status;
  final PaymentMethod paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderTime,
    required this.pickupTime,
    this.status = 'Pending',
    required this.paymentMethod,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    List<OrderItem> items =
        (data['items'] as List<dynamic>?)
            ?.map(
              (itemMap) => OrderItem.fromMap(itemMap as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderTime: (data['orderTime'] as Timestamp).toDate(),
      pickupTime: (data['pickupTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
        orElse: () => PaymentMethod.cash,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderTime': orderTime,
      'pickupTime': pickupTime,
      'status': status,
      'paymentMethod': paymentMethod.toString().split('.').last,
    };
  }
}
