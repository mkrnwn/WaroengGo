// lib/shopping_cart_service.dart
import 'package:flutter/material.dart';
import 'package:waroeng_go1/models.dart';

class ShoppingCartService extends ChangeNotifier {
  final List<OrderItem> _cartItems = [];

  List<OrderItem> get items => List.unmodifiable(_cartItems);

  void addItem(FoodItem foodItem, int quantity) {
    int existingIndex = _cartItems.indexWhere(
      (item) => item.foodItemId == foodItem.id,
    );

    if (existingIndex != -1) {
      OrderItem existingItem = _cartItems[existingIndex];
      _cartItems[existingIndex] = OrderItem(
        foodItemId: existingItem.foodItemId,
        foodName: existingItem.foodName,
        price: existingItem.price,
        quantity: existingItem.quantity + quantity,
        imageUrl: existingItem.imageUrl,
      );
    } else {
      _cartItems.add(
        OrderItem(
          foodItemId: foodItem.id,
          foodName: foodItem.name,
          price: foodItem.price,
          quantity: quantity,
          imageUrl: foodItem.imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String foodItemId) {
    _cartItems.removeWhere((item) => item.foodItemId == foodItemId);
    notifyListeners();
  }

  void updateQuantity(String foodItemId, int newQuantity) {
    int index = _cartItems.indexWhere(
      (item) => item.foodItemId == foodItemId,
    ); // <--- PERBAIKAN DI SINI
    ; // Perbaikan: menggunakan foodItem.id
    if (index != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        OrderItem existingItem = _cartItems[index];
        _cartItems[index] = OrderItem(
          foodItemId: existingItem.foodItemId,
          foodName: existingItem.foodName,
          price: existingItem.price,
          quantity: newQuantity,
          imageUrl: existingItem.imageUrl,
        );
      }
      notifyListeners();
    }
  }

  double get totalAmount {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  int get totalItemsCount {
    return _cartItems.length;
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
