import 'package:flutter/foundation.dart';
import '../models/product.dart';

class WishlistService {
  // Singleton pattern
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  // Wishlist products
  final ValueNotifier<List<Product>> wishlist = ValueNotifier<List<Product>>([]);

  // Add to wishlist
  void addToWishlist(Product product) {
    if (!isInWishlist(product)) {
      wishlist.value = [...wishlist.value, product];
    }
  }

  // Remove from wishlist
  void removeFromWishlist(Product product) {
    wishlist.value = wishlist.value.where((p) => p.id != product.id).toList();
  }

  // Toggle wishlist
  void toggleWishlist(Product product) {
    if (isInWishlist(product)) {
      removeFromWishlist(product);
    } else {
      addToWishlist(product);
    }
  }

  // Check if product is in wishlist
  bool isInWishlist(Product product) {
    return wishlist.value.any((p) => p.id == product.id);
  }
}
