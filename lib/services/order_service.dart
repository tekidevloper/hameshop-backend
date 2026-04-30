import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ValueNotifier<List<OrderModel>> orders = ValueNotifier<List<OrderModel>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore || (isLoading.value && !refresh)) return;

    isLoading.value = true;
    try {
      final response = await ApiClient().dio.get(
        '/orders',
        queryParameters: {
          'page': _currentPage.toString(),
          'limit': '20',
        },
        options: refresh ? Options(extra: {'dio_cache_force_refresh': true}) : null,
      );
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List<dynamic> data = [];
        
        if (responseData is Map) {
          data = responseData['orders'] is List ? responseData['orders'] : [];
          final dynamic pagesValue = responseData['pages'];
          try {
            _totalPages = int.tryParse(pagesValue?.toString() ?? '1') ?? 1;
          } catch (e) {
            _totalPages = 1;
          }
        } else if (responseData is List) {
          data = responseData;
          _totalPages = 1;
        }

        final List<OrderModel> newOrders = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          if (item is Map<String, dynamic>) {
            try {
              newOrders.add(OrderModel.fromJson(item));
            } catch (e) {
              if (kDebugMode) debugPrint('Error parsing order at index $i: $e');
            }
          } else if (item is Map) {
            try {
              newOrders.add(OrderModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              if (kDebugMode) debugPrint('Error parsing order (dynamic) at index $i: $e');
            }
          }
        }

        if (refresh) {
          orders.value = newOrders;
        } else {
          final existingIds = orders.value.map((o) => o.id).toSet();
          final filteredNew = newOrders.where((o) => !existingIds.contains(o.id)).toList();
          orders.value = [...orders.value, ...filteredNew];
        }

        _currentPage++;
        _hasMore = _currentPage <= _totalPages;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Fetch orders error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createOrder(OrderModel order) async {
    try {
      final response = await ApiClient().dio.post('/orders', data: order.toJson());
      if (response.statusCode == 201) {
        await fetchOrders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await ApiClient().dio.put('/orders/$orderId', data: {'status': newStatus});
      if (response.statusCode == 200) {
        await fetchOrders();
      }
    } catch (e) {
      debugPrint('Update order status error: $e');
    }
  }

  Future<void> updatePaymentStatus(String orderId, String newStatus) async {
    try {
      final response = await ApiClient().dio.put('/orders/$orderId', data: {'paymentStatus': newStatus});
      if (response.statusCode == 200) {
        await fetchOrders();
      }
    } catch (e) {
      debugPrint('Update payment status error: $e');
    }
  }

  List<OrderModel> getOrders() => orders.value;
}
