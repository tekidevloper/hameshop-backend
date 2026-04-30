import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/banner_model.dart';

class BannerService {
  static final BannerService _instance = BannerService._internal();
  factory BannerService() => _instance;
  BannerService._internal();

  final ValueNotifier<List<BannerModel>> banners = ValueNotifier<List<BannerModel>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> fetchBanners() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/banners');
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List<dynamic> data = [];
        
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = responseData['banners'] is List ? responseData['banners'] : [];
        }

        final List<BannerModel> newBanners = [];
        for (var json in data) {
          try {
            if (json is Map<String, dynamic>) {
              newBanners.add(BannerModel.fromJson(json));
            } else if (json is Map) {
              newBanners.add(BannerModel.fromJson(Map<String, dynamic>.from(json)));
            }
          } catch (e) {
            if (kDebugMode) debugPrint('Error parsing banner: $e');
          }
        }
        banners.value = newBanners;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Fetch banners error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> addBanner(String imageBase64) async {
    try {
      final response = await ApiClient().dio.post('/banners', data: {
        'imageUrl': imageBase64,
        'isActive': true,
        'order': 0,
      });

      if (response.statusCode == 201) {
        await fetchBanners(); // Refresh list
        return {'success': true};
      }
      return {'success': false, 'message': 'Status code: ${response.statusCode}'};
    } catch (e) {
      String message = e.toString();
      if (e is DioException) {
        message = e.response?.data?['error'] ?? e.message;
        debugPrint('Add banner error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        debugPrint('Add banner error: $e');
      }
      return {'success': false, 'message': message};
    }
  }

  Future<bool> deleteBanner(String id) async {
    try {
      final response = await ApiClient().dio.delete('/banners/$id');

      if (response.statusCode == 200) {
        await fetchBanners(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete banner error: $e');
      return false;
    }
  }
}
