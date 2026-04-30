import 'package:flutter/foundation.dart';
import '../models/product.dart';

class RecentlyViewedService {
  static final RecentlyViewedService _instance = RecentlyViewedService._internal();
  factory RecentlyViewedService() => _instance;
  RecentlyViewedService._internal();

  final ValueNotifier<List<Product>> recentlyViewed = ValueNotifier<List<Product>>([]);

  void addProduct(Product product) {
    List<Product> current = List.from(recentlyViewed.value);
    // Remove if already exists to move to top
    current.removeWhere((p) => p.id == product.id);
    // Add to front
    current.insert(0, product);
    // Keep only last 10
    if (current.length > 10) {
      current = current.sublist(0, 10);
    }
    // Use microtask to avoid setState() during build if this is called from initState
    Future.microtask(() {
      recentlyViewed.value = current;
    });
  }
}
