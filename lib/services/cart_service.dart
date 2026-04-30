import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../models/product.dart';

class CartService {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // Cart items
  final ValueNotifier<List<CartItem>> cartItems = ValueNotifier<List<CartItem>>([]);

  // Add to cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = cartItems.value.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      // Product already in cart, increase quantity
      final updatedItems = List<CartItem>.from(cartItems.value);
      updatedItems[existingIndex].quantity += quantity;
      cartItems.value = updatedItems;
    } else {
      // Add new product to cart
      cartItems.value = [...cartItems.value, CartItem(product: product, quantity: quantity)];
    }
  }

  // Remove from cart
  void removeFromCart(Product product) {
    cartItems.value = cartItems.value.where((item) => item.product.id != product.id).toList();
  }

  // Update quantity
  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeFromCart(product);
      return;
    }

    final updatedItems = List<CartItem>.from(cartItems.value);
    final index = updatedItems.indexWhere((item) => item.product.id == product.id);
    
    if (index != -1) {
      updatedItems[index].quantity = quantity;
      cartItems.value = updatedItems;
    }
  }

  // Clear cart
  void clearCart() {
    cartItems.value = [];
  }

  // Get total price
  double get totalPrice {
    return cartItems.value.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get total items count
  int get itemCount {
    return cartItems.value.fold(0, (sum, item) => sum + item.quantity);
  }

  // Check if product is in cart
  bool isInCart(Product product) {
    return cartItems.value.any((item) => item.product.id == product.id);
  }
}
