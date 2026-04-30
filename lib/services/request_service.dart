import 'package:flutter/foundation.dart';
import '../models/request_model.dart';
import 'api_client.dart';

class RequestService {
  static final RequestService _instance = RequestService._internal();
  factory RequestService() => _instance;
  RequestService._internal();

  final ValueNotifier<List<RequestModel>> requests = ValueNotifier<List<RequestModel>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<void> fetchAllRequests() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/requests');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        requests.value = data.map((json) => RequestModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch all requests error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyRequests() async {
    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get('/requests/my');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        requests.value = data.map((json) => RequestModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Fetch my requests error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createRequest(String title, String message, String category) async {
    try {
      final response = await ApiClient().dio.post('/requests', data: {
        'title': title,
        'message': message,
        'category': category,
      });
      if (response.statusCode == 201) {
        await fetchMyRequests();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> respondToRequest(String id, String adminResponse, String status) async {
    try {
      final response = await ApiClient().dio.put('/requests/$id', data: {
        'adminResponse': adminResponse,
        'status': status,
      });
      if (response.statusCode == 200) {
        await fetchAllRequests();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
