import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ValueNotifier<List<Product>> products = ValueNotifier<List<Product>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      // Note: We don't clear products.value immediately to avoid UI flickering
    }

    if (!_hasMore || (isLoading.value && !refresh)) return;

    isLoading.value = true;
    try {
      if (kDebugMode) print('ApiClient: GET /products - Page: $_currentPage');
      final response = await ApiClient().dio.get(
        '/products',
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
          data = responseData['products'] is List ? responseData['products'] : [];
          final dynamic pagesValue = responseData['pages'];
          try {
            _totalPages = int.tryParse(pagesValue?.toString() ?? '1') ?? 1;
          } catch (e) {
            _totalPages = 1;
          }
        } else if (responseData is List) {
          data = responseData;
          _totalPages = 1; // No pagination info in raw list
        } else {
          if (kDebugMode) print('Error: Unknown response data type: ${responseData.runtimeType}');
          return;
        }

        final List<Product> newProducts = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          if (item is Map<String, dynamic>) {
            try {
              newProducts.add(Product.fromJson(item));
            } catch (e) {
              if (kDebugMode) print('Error parsing product at index $i: $e. Data: $item');
            }
          } else if (item is Map) {
            try {
              newProducts.add(Product.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              if (kDebugMode) print('Error parsing product (dynamic map) at index $i: $e');
            }
          }
        }

        if (refresh) {
          products.value = newProducts;
        } else {
          final existingIds = products.value.map((p) => p.id).toSet();
          final filteredNew = newProducts.where((p) => !existingIds.contains(p.id)).toList();
          products.value = [...products.value, ...filteredNew];
        }

        _currentPage++;
        _hasMore = _currentPage <= _totalPages;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Fetch products error: $e');
        print('Stack trace: $stackTrace');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct(Product product) async {
    try {
      if (kDebugMode) print('POST /products with data: ${product.toJson()}');
      final response = await ApiClient().dio.post('/products', data: product.toJson());
      if (kDebugMode) print('POST /products response status: ${response.statusCode}');
      if (response.statusCode == 201) {
        await fetchProducts(refresh: true); // Refresh list from start
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Add product error: $e');
        if (e is DioException) {
          print('Dio error response: ${e.response?.data}');
          print('Dio error status: ${e.response?.statusCode}');
        }
      }
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final response = await ApiClient().dio.put('/products/${product.id}', data: product.toJson());
      if (response.statusCode == 200) {
        await fetchProducts(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await ApiClient().dio.delete('/products/$id');
      if (response.statusCode == 200) {
        await fetchProducts(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
