import '../models/product.dart';
import '../models/review_model.dart';
import 'product_service.dart';
import 'review_service.dart';

class MockDataService {
  static List<Product> getProducts() {
    return ProductService().products.value;
  }

  static List<String> getBanners() {
    return [
      'https://picsum.photos/seed/banner1/600/300',
      'https://picsum.photos/seed/banner2/600/300',
      'https://picsum.photos/seed/banner3/600/300',
    ];
  }

  static Future<List<Review>> getReviews(String productId) async {
    return ReviewService().getProductReviews(productId);
  }
}
