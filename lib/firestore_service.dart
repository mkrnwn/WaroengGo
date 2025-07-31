// lib/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:waroeng_go1/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Operasi Item Makanan (Food Item Operations) ---

  // MODIFIKASI: Menerima kategori opsional untuk filtering
  Stream<List<FoodItem>> getFoodItems({String? category}) {
    Query query = _db.collection('food_items');
    if (category != null && category.isNotEmpty && category != 'Semua') {
      // Jika kategori dipilih (dan bukan 'Semua'), filter berdasarkan kategori
      query = query.where('category', isEqualTo: category);
    }
    // Anda bisa tambahkan orderBy di sini juga jika ingin pengurutan default
    // query = query.orderBy('name'); // Contoh pengurutan
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList();
    });
  }

  Future<void> addFoodItem(FoodItem item) {
    return _db.collection('food_items').add(item.toMap());
  }

  Future<void> updateFoodItem(FoodItem item) {
    return _db.collection('food_items').doc(item.id).update(item.toMap());
  }

  Future<void> deleteFoodItem(String itemId) {
    return _db.collection('food_items').doc(itemId).delete();
  }

  // --- Operasi Pesanan (Order Operations) ---

  Future<void> placeOrder(Order order) async {
    WriteBatch batch = _db.batch();

    // 1. Kurangi stok makanan
    for (var item in order.items) {
      DocumentReference foodRef = _db
          .collection('food_items')
          .doc(item.foodItemId);
      batch.update(foodRef, {'stock': FieldValue.increment(-item.quantity)});
    }

    // 2. Tambahkan pesanan ke koleksi 'orders'
    batch.set(_db.collection('orders').doc(), order.toMap());

    return batch.commit();
  }

  Stream<List<Order>> getOrdersForUser(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
        });
  }

  Stream<List<Order>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('orderTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
        });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) {
    return _db.collection('orders').doc(orderId).update({'status': newStatus});
  }
}
