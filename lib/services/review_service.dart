import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import 'api_client.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<List<Review>> getProductReviews(String productId) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/products/$productId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Review.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get reviews error: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addReview(Review review) async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.post('/reviews', data: review.toJson());
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Add review error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
