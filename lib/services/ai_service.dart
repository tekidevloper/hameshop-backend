import '../models/product.dart';
import 'mock_data_service.dart';
import 'recently_viewed_service.dart';

class AIService {
  static Future<List<Product>> getRecommendations() async {
    // Artificial delay removed for optimization
    final allProducts = MockDataService.getProducts();
    final recentlyViewed = RecentlyViewedService().recentlyViewed.value;
    
    if (recentlyViewed.isNotEmpty) {
      // Get categories of recently viewed items
      final categories = recentlyViewed.map((p) => p.category).toSet();
      // Filter products from the same categories that haven't been viewed yet
      final recommendations = allProducts.where((p) {
        return categories.contains(p.category) && !recentlyViewed.any((rv) => rv.id == p.id);
      }).toList();
      
      if (recommendations.isNotEmpty) {
        recommendations.shuffle();
        return recommendations.take(3).toList();
      }
    }

    // Fallback: Return random products
    final fallback = List<Product>.from(allProducts);
    fallback.shuffle();
    return fallback.take(3).toList();
  }
}
